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
import '../base/base_cubit.dart';

//blocs
import '../../blocs/processing_queue/processing_queue_bloc.dart';
import 'package:bexdeliveries/src/presentation/blocs/network/network_bloc.dart';
import '../../blocs/gps/gps_bloc.dart';

//utils
import '../../../utils/resources/data_state.dart';
import '../../../utils/constants/strings.dart';
import '../../../utils/extensions/list_extension.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/models/warehouse.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/summary.dart' as s;
import '../../../domain/models/transaction.dart';
import '../../../domain/models/processing_queue.dart';
// import '../../../domain/models/note.dart';

import '../../../domain/repositories/database_repository.dart';
import '../../../domain/repositories/api_repository.dart';

import '../../../domain/abstracts/format_abstract.dart';
//request
import '../../../domain/models/requests/login_request.dart';
import '../../../domain/models/requests/work_request.dart';
import '../../../domain/models/requests/account_request.dart';
import '../../../domain/models/requests/reason_request.dart';
import '../../../domain/models/requests/enterprise_config_request.dart';
//responses
import '../../../domain/models/responses/enterprise_config_response.dart';
import '../../../domain/models/responses/reason_response.dart';

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
  final ProcessingQueueBloc _processingQueueBloc;
  final GpsBloc gpsBloc;
  final NetworkBloc networkBloc;
  bool _isLoggingOut = false;
  bool _isSyncing = false;

  StreamSubscription? locationSubscription;
  CurrentUserLocationEntity? currentLocation;

  HomeCubit(this._databaseRepository, this._apiRepository,
      this._processingQueueBloc, this.gpsBloc, this.networkBloc)
      : super(const HomeState(status: HomeStatus.initial), null);

  Future<void> getAllWorks() async {
    emit(await _getAllWorks());
  }

  void getUser() {
    final user = _storageService.getObject('user') != null
        ? User.fromJson(_storageService.getObject('user')!)
        : null;
    updateUser(user);
  }

  Future<HomeState> _getAllWorks() async {
    final works = await _databaseRepository.getAllWorks();

    var futures = <Future>[];

    for (var work in works) {
      futures.add(_databaseRepository.countLeftClients(work.workcode!));
    }

    var response = await Future.wait(futures);
    var i = 0;
    for (var left in response) {
      works[i].left = left;
      i++;
    }

    final user = _storageService.getObject('user') != null
        ? User.fromJson(_storageService.getObject('user')!)
        : null;

    return HomeState(status: HomeStatus.success, works: works, user: user);
  }

  void updateUser(User? user) {
    emit(state.copyWith(user: user));
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
    try {
      if (_isSyncing) return;
      _isSyncing = true;

      await run(() async {
        emit(state.copyWith(status: HomeStatus.loading));

        if (networkBloc.state is NetworkSuccess) {
          final timer0 = logTimerStart(headerHomeLogger, 'Starting...',
              level: LogLevel.info);

          var currentLocation = gpsBloc.state.lastKnownLocation;

          final user = _storageService.getObject('user') != null
              ? User.fromJson(_storageService.getObject('user')!)
              : null;

          final results = await Future.wait([
            _apiRepository.getConfigEnterprise(
                request: EnterpriseConfigRequest()),
            _apiRepository.reasons(request: ReasonRequest()),
          ]);

          if (results.isNotEmpty) {
            if (results[0] is DataSuccess) {
              var data = results[0].data as EnterpriseConfigResponse;
              _storageService.setObject(
                  'config', data.enterpriseConfig.toMap());
              _storageService.setBool(
                  'can_make_history', data.enterpriseConfig.canMakeHistory);
              _storageService.setInt(
                  'limit_days_works', data.enterpriseConfig.limitDaysWorks);
              if (data.enterpriseConfig.specifiedAccountTransfer == true) {
                var response =
                    await _apiRepository.accounts(request: AccountRequest());
                if (response is DataSuccess) {
                  await _databaseRepository
                      .insertAccounts(response.data!.accounts);
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
            final login = response!.data!.login;
            var yaml = loadYaml(await rootBundle.loadString('pubspec.yaml'));
            var version = yaml['version'];
            _storageService.setString('token', response.data!.login.token);
            _storageService.setObject(
                'user', response.data!.login.user!.toJson());
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
              var summaries = <s.Summary>[];
              var transactions = <Transaction>[];

              await Future.forEach(responseWorks.data!.works, (work) async {
                works.add(work);
                if (work.summaries != null) {
                  await Future.forEach(work.summaries as Iterable<Object?>,
                      (element) {
                    var summary = element as s.Summary;
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

              var worksF =
                  groupBy(responseWorks.data!.works, (Work o) => o.workcode);
              var warehouses = <Warehouse>[];
              for (var w in worksF.keys) {
                var wn = responseWorks.data!.works
                    .where((element) => element.workcode == w);
                warehouses.add(wn.first.warehouse!);
              }
              final distinct = warehouses.unique((x) => x.id);
              await _databaseRepository.insertWarehouses(distinct);

              var workcodes = groupBy(works, (Work work) => work.workcode);
              if (workcodes.isNotEmpty) {
                var localWorks = await _databaseRepository.getAllWorks();
                var localWorkcode =
                    groupBy(localWorks, (Work obj) => obj.workcode);
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

                  if (worksF.first.zoneId != null &&
                      _storageService.getBool('can_make_history') == true) {
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

              logTimerStop(headerHomeLogger, timer0, 'Initialization completed',
                  level: LogLevel.success);

              for (var work in works) {
                await helperFunctions.deleteWorks(work);
              }
              emit(await _getAllWorks());
            } else {
              emit(state.copyWith(
                  status: HomeStatus.failure,
                  error: responseWorks.error,
                  user: user));
            }
          } else if (response is DataFailed) {
            emit(state.copyWith(
                status: HomeStatus.failure, error: response!.error, user: user));
          }
        } else {
          emit(state.copyWith(
              status: HomeStatus.failure,
              error:
                  'Porfavor conectate a internet para realizar esta accion'));
        }
      });
    } catch (e, stackTrace) {
      print("Error during sync: $e");
      print(stackTrace);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> logout() async {
    if (_isLoggingOut) return;
    try {
      _isLoggingOut = true;
      emit(state.copyWith(status: HomeStatus.loading));

      if (networkBloc.state is NetworkSuccess) {
        var vpq =
            await _databaseRepository.validateIfProcessingQueueIsIncomplete();
        if (vpq) {
          emit(state.copyWith(
              status: HomeStatus.failure,
              error:
                  'Existe procesamiento incompleto, porfavor espera para realizar esta acción'));
        } else {
          var processingQueueWork = ProcessingQueue(
              body: null,
              task: 'incomplete',
              code: 'post_logout',
              createdAt: now(),
              updatedAt: now());

          _processingQueueBloc
              .add(ProcessingQueueAdd(processingQueue: processingQueueWork));

          await _databaseRepository.emptyWorks();
          await _databaseRepository.emptySummaries();
          await _databaseRepository.emptyTransactions();
          await _databaseRepository.emptyReasons();
          // await _databaseRepository.emptyNotes();
          _storageService.remove('user');
          _storageService.remove('token');
          _storageService.remove('can_make_history');

          emit(state.copyWith(status: HomeStatus.success));
          _isLoggingOut = false;
          await _navigationService.goTo(AppRoutes.login);
        }
      } else {
        emit(state.copyWith(
            status: HomeStatus.failure,
            error: 'Porfavor conectate a internet para realizar esta accion'));
        _isLoggingOut = false;
      }
    } catch (e, stackTrace) {
      print("Error during logout: $e");
      print(stackTrace);
      _isLoggingOut = false;
    } finally {
      _isLoggingOut = false;
    }
  }
}
