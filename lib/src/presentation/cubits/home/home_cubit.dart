import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'package:location_repository/location_repository.dart';
import 'package:equatable/equatable.dart';

//core
import '../../../../core/helpers/index.dart';

//cubit
import '../../../domain/models/requests/account_request.dart';
import '../../../domain/models/requests/enterprise_config_request.dart';
import '../../../domain/models/requests/reason_request.dart';
import '../../../domain/models/responses/enterprise_config_response.dart';
import '../../../domain/models/responses/reason_response.dart';
import '../../blocs/gps/gps_bloc.dart';
import '../base/base_cubit.dart';

//blocs
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//utils
import '../../../utils/resources/data_state.dart';
import '../../../utils/constants/strings.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/summary.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/processing_queue.dart';

import '../../../domain/repositories/database_repository.dart';
import '../../../domain/repositories/api_repository.dart';

import '../../../domain/abstracts/format_abstract.dart';

import '../../../domain/models/requests/login_request.dart';
import '../../../domain/models/requests/work_request.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';
import '../../../services/logger.dart';

part 'home_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();
final helperFunctions = HelperFunctions();

class HomeCubit extends BaseCubit<HomeState, String?> with FormatDate {
  final ApiRepository _apiRepository;
  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final GpsBloc gpsBloc;

  StreamSubscription? locationSubscription;
  CurrentUserLocationEntity? currentLocation;

  HomeCubit(this._databaseRepository, this._apiRepository,
      this._locationRepository, this._processingQueueBloc, this.gpsBloc)
      : super(const HomeLoading(), null);

  Future<void> getAllWorks() async {
    emit(await _getAllWorks());
  }

  void getUser() {
    final user = _storageService.getObject('user') != null
        ? User.fromJson(_storageService.getObject('user')!)
        : null;
    updateUser(user!);
  }

  Future<HomeState> _getAllWorks() async {
    final works = await _databaseRepository.getAllWorks();
    final user = _storageService.getObject('user') != null
        ? User.fromJson(_storageService.getObject('user')!)
        : null;

    return HomeSuccess(works: works, user: user);
  }

  void updateUser(User user) {
    emit(UpdateUser(user));
  }

  Future<void> differenceWorks(
      List<String?> localWorks, List<String?> externalWorks) async {
    var difference =
        localWorks.toSet().difference(externalWorks.toSet()).toList();
    if (difference.isNotEmpty) {
      for (var key in difference) {
        await _databaseRepository.updateStatusWork(key!, 'complete');
      }
    }
  }

  Future<void> sync() async {
    if (isBusy) return;

    await run(() async {
      emit(const HomeLoading());

      final timer0 =
          logTimerStart(headerLogger, 'Starting...', level: LogLevel.info);

      var currentLocation = gpsBloc.state.lastKnownLocation;

      final user = _storageService.getObject('user') != null
          ? User.fromJson(_storageService.getObject('user')!)
          : null;

      final results = await Future.wait([
        _apiRepository.getConfigEnterprise(request: EnterpriseConfigRequest()),
        _apiRepository.reasons(request: ReasonRequest()),
      ]);

      if (results.isNotEmpty) {
        if (results[0] is DataSuccess) {
          var data = results[0].data as EnterpriseConfigResponse;
          _storageService.setObject('config', data.enterpriseConfig.toMap());
          if (data.enterpriseConfig.specifiedAccountTransfer == true) {
            var response =
                await _apiRepository.accounts(request: AccountRequest());
            if (response is DataSuccess) {
              _databaseRepository.insertAccounts(response.data!.accounts);
            }
          }
        }

        if (results[1] is DataSuccess) {
          var data = results[1].data as ReasonResponse;
          _databaseRepository.insertReasons(data.reasons);
        }
      }

      final response = await _apiRepository.login(
        request: LoginRequest(_storageService.getString('username')!,
            _storageService.getString('password')!),
      );

      if (response is DataSuccess) {
        final login = response.data!.login;
        var yaml = loadYaml(await rootBundle.loadString('pubspec.yaml'));
        var version = yaml['version'];
        _storageService.setString('token', response.data!.login.token);
        _storageService.setObject('user', response.data!.login.user!.toJson());
        _storageService.setInt('user_id', response.data!.login.user!.id);

        var device = await helperFunctions.getDevice();

        final responseWorks = await _apiRepository.works(
            request: WorkRequest(
                login.user!.id!,
                device != null ? device['id'] : null,
                device != null ? device['model'] : null,
                version,
                currentLocation?.latitude.toString(),
                currentLocation?.longitude.toString(),
                DateTime.now().toIso8601String(),
                'sync'));

        if (responseWorks is DataSuccess) {
          var works = <Work>[];
          var summaries = <Summary>[];
          var transactions = <Transaction>[];

          await Future.forEach(responseWorks.data!.works, (work) async {
            works.add(work);
            if (work.summaries != null) {
              await Future.forEach(work.summaries as Iterable<Object?>,
                  (element) {
                var summary = element as Summary;
                if (summary.idPacking != null && summary.packing != null) {
                  summary.cant = 1;
                } else {
                  summary.cant = ((double.parse(summary.amount) *
                              100.0 /
                              double.parse(summary.unitOfMeasurement))
                          .round() /
                      100);
                }
                summary.grandTotalCopy = summary.grandTotal;

                print(summary.transaction);
                if (summary.transaction != null) {
                  transactions.add(summary.transaction!);
                }
                summaries.add(summary);
              });

              var found = work.summaries!
                  .where((element) => element.transaction != null);

              if (found.isNotEmpty) {
                _storageService.setBool('${work.workcode}-started', true);
                _storageService.setBool('${work..workcode}-confirm', true);
                _storageService.setBool('${work.workcode}-blocked', false);
              }
            }
          });

          //TODO:: refactoring
          var workcodes = groupBy(works, (Work work) => work.workcode);
          if (workcodes.isNotEmpty) {
            var localWorks = await _databaseRepository.getAllWorks();
            var localWorkcode = groupBy(localWorks, (Work obj) => obj.workcode);
            await differenceWorks(
                localWorkcode.keys.toList(), workcodes.keys.toList());
          }

          for (var key in groupBy(works, (Work obj) => obj.workcode).keys) {
            var worksF = works.where((element) => element.workcode == key);

            if (worksF.first.status == 'unsync') {
              var processingQueueWork = ProcessingQueue(
                  body: jsonEncode({'workcode': key, 'status': 'sync'}),
                  task: 'incomplete',
                  code: 'store_work_status',
                  createdAt: now(),
                  updatedAt: now());

              _processingQueueBloc.add(
                  ProcessingQueueAdd(processingQueue: processingQueueWork));

              if (worksF.first.zoneId != null) {
                var processingQueueHistoric = ProcessingQueue(
                    body: jsonEncode({
                      'zone_id': worksF.first.zoneId!,
                      'workcode': worksF.first.workcode
                    }),
                    task: 'incomplete',
                    code: 'get_prediction',
                    createdAt: now(),
                    updatedAt: now());

                _processingQueueBloc.add(ProcessingQueueAdd(
                    processingQueue: processingQueueHistoric));
              }
            }
          }

          await _databaseRepository.insertWorks(works);
          await _databaseRepository.insertSummaries(summaries);
          await _databaseRepository.insertTransactions(transactions);
          //DELETE
          await _databaseRepository.deleteProcessingQueueByDays();
          await _databaseRepository.deleteLocationsByDays();
          await _databaseRepository.deleteNotificationsByDays();

          logTimerStop(headerLogger, timer0, 'Initialization completed',
              level: LogLevel.success);

          for (var work in works) {
            await helperFunctions.deleteWorks(work);
          }
          emit(await _getAllWorks());
        } else {
          emit(HomeFailed(error: responseWorks.error, user: user));
        }
      } else if (response is DataFailed) {
        emit(HomeFailed(error: response.error, user: user));
      }
    });
  }

  Future<void> logout() async {
    if (isBusy) return;

    await run(() async {
      emit(const HomeLoading());

      await _databaseRepository.emptyWorks();
      await _databaseRepository.emptySummaries();
      await _databaseRepository.emptyTransactions();
      await _databaseRepository.emptyReasons();

      _storageService.remove('user');
      _storageService.remove('token');

      await _navigationService.goTo(loginRoute);
    });
  }
}
