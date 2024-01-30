import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

//domain
import '../../../../core/helpers/index.dart';

///models
import '../../../domain/models/login.dart';
import '../../../domain/models/enterprise.dart';
import '../../../domain/models/warehouse.dart';
import '../../../domain/models/work.dart';
import '../../../domain/models/summary.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/processing_queue.dart';

///requests
import '../../../domain/models/requests/login_request.dart';
import '../../../domain/models/requests/work_request.dart';
import '../../../domain/models/requests/enterprise_config_request.dart';
import '../../../domain/models/requests/reason_request.dart';
import '../../../domain/models/requests/account_request.dart';

///responses
import '../../../domain/models/responses/reason_response.dart';
import '../../../domain/models/responses/enterprise_config_response.dart';

///repositories
import '../../../domain/repositories/api_repository.dart';
import '../../../domain/repositories/database_repository.dart';
//abstracts
import '../../../domain/abstracts/format_abstract.dart';

//bloc
import '../../../services/geolocator.dart';
import '../../blocs/gps/gps_bloc.dart';
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//cubit
import '../base/base_cubit.dart';

//utils
import '../../../utils/resources/data_state.dart';
import '../../../utils/constants/strings.dart';
import '../../../utils/extensions/list_extension.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'login_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();

class LoginCubit extends BaseCubit<LoginState, Login?> with FormatDate {
  final ApiRepository _apiRepository;
  final DatabaseRepository _databaseRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final GpsBloc gpsBloc;


  var helperFunctions = HelperFunctions();

  LoginCubit(this._apiRepository, this._databaseRepository,
      this._processingQueueBloc, this.gpsBloc)
      : super(
            LoginSuccess(
                enterprise: _storageService.getObject('enterprise') != null
                    ? Enterprise.fromMap(
                        _storageService.getObject('enterprise')!)
                    : null),
            null);

  void updateEnterpriseState(Enterprise enterprise) {
    emit(UpdateEnterprise(enterprise));
  }

  Future<void> getConfigEnterprise() async {
    var response = await _apiRepository.getConfigEnterprise(
        request: EnterpriseConfigRequest());
    if (response is DataSuccess) {
      var data = response.data as EnterpriseConfigResponse;
      _storageService.setObject('config', data.enterpriseConfig.toMap());
      _storageService.setInt(
          'limit_days_works', data.enterpriseConfig.limitDaysWorks);
    }
  }

  Future<void> getReasons() async {
    var response = await _apiRepository.reasons(request: ReasonRequest());
    if (response is DataSuccess) {
      var data = response.data as ReasonResponse;
      _databaseRepository.insertReasons(data.reasons);
    }
  }

  Future<void> getAccounts() async {
    var response = await _apiRepository.accounts(request: AccountRequest());
    if (response is DataSuccess) {
      _databaseRepository.insertAccounts(response.data!.accounts);
    }
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

  Future<void> onPressedLogin(TextEditingController usernameController,
      TextEditingController passwordController, bool remember) async {
    if (isBusy) return;

    await run(() async {
      emit(LoginLoading(
          enterprise: _storageService.getObject('enterprise') != null
              ? Enterprise.fromMap(_storageService.getObject('enterprise')!)
              : null));

      if (remember) {
        _storageService.setString('username', usernameController.text);
        _storageService.setString('password', passwordController.text);
      }

      //var currentLocation = gpsBloc.state.lastKnownLocation;
      //var currentLocation = gpsBloc.state.lastKnownLocation;
      var location = await acquireCurrentLocationGeo();


      final response = await _apiRepository.login(
        request: LoginRequest(usernameController.text, passwordController.text),
      );

      if (response is DataSuccess) {
        final login = response!.data!.login;

        var yaml = loadYaml(await rootBundle.loadString('pubspec.yaml'));
        var version = yaml['version'];
        var token = await FirebaseMessaging.instance.getToken();

        _storageService.setString('username', usernameController.text);
        _storageService.setString('password', passwordController.text);
        _storageService.setString('token', response.data!.login.token);
        _storageService.setObject('user', response.data!.login.user!.toJson());
        _storageService.setInt('user_id', response.data!.login.user!.id);
        _storageService.setString('fcm_token', token);

        Future.wait([getConfigEnterprise(), getReasons(), getAccounts()]);

        var device = await helperFunctions.getDevice();

        var processingQueue = ProcessingQueue(
          body: jsonEncode({
            'user_id': _storageService.getInt('user_id')!.toString(),
            'fcm_token': '${_storageService.getString('fcm_token')}'
          }),
          task: 'incomplete',
          code: 'post_firebase_token',
          createdAt: now(),
          updatedAt: now(),
        );

        _processingQueueBloc
            .add(ProcessingQueueAdd(processingQueue: processingQueue));

        final responseWorks = await _apiRepository.works(
            request: WorkRequest(
                login.user!.id!,
                device != null ? device['id'] : null,
                device != null ? device['model'] : null,
                version,
                location!.latitude.toString(),
                location.longitude.toString(),
                now(),
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
                summary.cant = ((double.parse(summary.amount) *
                            100.0 /
                            double.parse(summary.unitOfMeasurement))
                        .round() /
                    100);

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
            error: response!.error,
            enterprise: _storageService.getObject('enterprise') != null
                ? Enterprise.fromMap(_storageService.getObject('enterprise')!)
                : null));
      }
    });
  }

  void goToHome() {
    _navigationService.replaceTo(AppRoutes.home);
  }

  void goToCompany() {
    _storageService.remove('company');
    _storageService.remove('enterprise');

    _navigationService.replaceTo(AppRoutes.company);
  }
}
