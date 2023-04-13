import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:yaml/yaml.dart';
import 'package:location_repository/location_repository.dart';

//domain
///models
import '../../../domain/models/login.dart';
import '../../../domain/models/enterprise.dart';
import '../../../domain/models/work.dart';
import '../../../domain/models/summary.dart';
import '../../../domain/models/transaction.dart';
///requests
import '../../../domain/models/requests/login_request.dart';
import '../../../domain/models/requests/work_request.dart';
import '../../../domain/models/requests/enterprise_config_request.dart';
import '../../../domain/models/requests/reason_request.dart';
///responses
import '../../../domain/models/responses/reason_response.dart';
import '../../../domain/models/responses/enterprise_config_response.dart';
///repositories
import '../../../domain/repositories/api_repository.dart';
import '../../../domain/repositories/database_repository.dart';

//cubit
import '../base/base_cubit.dart';

//utils
import '../../../utils/resources/data_state.dart';
import '../../../utils/constants/strings.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'login_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();

class LoginCubit extends BaseCubit<LoginState, Login?> {
  final ApiRepository _apiRepository;
  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;

  CurrentUserLocationEntity? currentLocation;

  LoginCubit(this._apiRepository, this._databaseRepository, this._locationRepository)
      : super(
            LoginSuccess(
                enterprise: _storageService.getObject('enterprise') != null
                    ? Enterprise.fromMap(
                        _storageService.getObject('enterprise')!)
                    : null),
            null);

  Future<void> onPressedLogin(TextEditingController usernameController,
      TextEditingController passwordController) async {
    if (isBusy) return;

    await run(() async {
      emit(LoginLoading(
          enterprise: _storageService.getObject('enterprise') != null
              ? Enterprise.fromMap(_storageService.getObject('enterprise')!)
              : null));

      currentLocation = await _locationRepository.getCurrentLocation();

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
        request: LoginRequest(usernameController.text, passwordController.text),
      );

      if (response is DataSuccess) {
        final login = response.data!.login;

        var yaml = loadYaml(await rootBundle.loadString('pubspec.yaml'));
        var version = yaml['version'];

        _storageService.setString('username', usernameController.text);
        _storageService.setString('password', passwordController.text);
        _storageService.setString('token', response.data!.login.token);
        _storageService.setObject('user', response.data!.login.user!.toMap());

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
                'login'));

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
                  summary.cant = ((double.parse(summary.amount) * 100.0 / double.parse(summary.unitOfMeasurement)).round() / 100);
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

          emit(LoginSuccess(
              login: login,
              enterprise: _storageService.getObject('enterprise') != null
                  ? Enterprise.fromMap(_storageService.getObject('enterprise')!)
                  : null));
        } else {
          emit(LoginFailed(
              error: responseWorks.error,
              enterprise: _storageService.getObject('enterprise') != null
                  ? Enterprise.fromMap(_storageService.getObject('enterprise')!)
                  : null));
        }
      } else if (response is DataFailed) {
        emit(LoginFailed(
            error: response.error,
            enterprise: _storageService.getObject('enterprise') != null
                ? Enterprise.fromMap(_storageService.getObject('enterprise')!)
                : null));
      }
    });
  }

  void goToHome() {
    _navigationService.replaceTo(homeRoute);
  }

  void goToCompany() {
    _storageService.remove('company_name');
    _storageService.remove('enterprise');

    _navigationService.replaceTo(companyRoute);

  }
}
