import 'dart:async';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'package:location_repository/location_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_udid/flutter_udid.dart';

//cubit
import '../base/base_cubit.dart';

//utils
import '../../../utils/resources/data_state.dart';
import '../../../utils/constants/strings.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/summary.dart';
import '../../../domain/models/transaction.dart';

import '../../../domain/repositories/database_repository.dart';
import '../../../domain/repositories/api_repository.dart';

import '../../../domain/models/requests/login_request.dart';
import '../../../domain/models/requests/work_request.dart';
import '../../../domain/models/responses/enterprise_config_response.dart';
import '../../../domain/models/responses/reason_response.dart';
import '../../../domain/models/requests/enterprise_config_request.dart';
import '../../../domain/models/requests/reason_request.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'home_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();

class HomeCubit extends BaseCubit<HomeState, String?> {
  final ApiRepository _apiRepository;
  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;

  StreamSubscription? locationSubscription;
  CurrentUserLocationEntity? currentLocation;

  HomeCubit(
      this._databaseRepository, this._apiRepository, this._locationRepository)
      : super(const HomeLoading(), null);

  Future<void> getAllWorks() async {
    emit(await _getAllWorks());
  }

  Future<HomeState> _getAllWorks() async {
    final works = await _databaseRepository.getAllWorks();
    final user = _storageService.getObject('user') != null
        ? User.fromMap(_storageService.getObject('user')!)
        : null;

    return HomeSuccess(works: works, user: user);
  }

  Future<void> sync() async {
    if (isBusy) return;

    await run(() async {
      emit(const HomeLoading());

      currentLocation = await _locationRepository.getCurrentLocation();

      final user = _storageService.getObject('user') != null
          ? User.fromMap(_storageService.getObject('user')!)
          : null;

      final results = await Future.wait([
        _apiRepository.getConfigEnterprise(request: EnterpriseConfigRequest()),
        _apiRepository.reasons(request: ReasonRequest()),
      ]);

      if (results.isNotEmpty) {
        if (results[0] is DataSuccess) {
          var data = results[0].data as EnterpriseConfigResponse;
          _storageService.setObject('config', data.enterpriseConfig.toMap());
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
        _storageService.setObject('user', response.data!.login.user!.toMap());
        _storageService.setInt('user_id', response.data!.login.user!.id);

        String udid = await FlutterUdid.udid;

        final responseWorks = await _apiRepository.works(
            request: WorkRequest(
                login.user!.id!,
                udid,
                'SM-A336M',
                version,
                currentLocation!.latitude.toString(),
                currentLocation!.longitude.toString(),
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

          await _databaseRepository.insertWorks(works);
          await _databaseRepository.insertSummaries(summaries);
          await _databaseRepository.insertTransactions(transactions);

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
