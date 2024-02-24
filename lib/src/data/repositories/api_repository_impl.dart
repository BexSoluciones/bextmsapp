//utils
import 'dart:convert';
import 'dart:io';
import 'package:workmanager/workmanager.dart';

import 'package:bexdeliveries/src/domain/models/requests/reason_m_request.dart';
import 'package:bexdeliveries/src/domain/models/requests/routing_request.dart';
import 'package:bexdeliveries/src/domain/models/responses/routing_response.dart';

import '../../domain/models/requests/locations_request.dart';
import '../../utils/resources/data_state.dart';

import '../../domain/models/requests/login_request.dart';
import '../../domain/models/responses/login_response.dart';

import '../../domain/models/requests/logout_request.dart';
import '../../domain/models/responses/logout_response.dart';

import '../../domain/models/requests/enterprise_request.dart';
import '../../domain/models/responses/enterprise_response.dart';

import '../../domain/models/requests/work_request.dart';
import '../../domain/models/responses/work_response.dart';

import '../../domain/models/requests/database_request.dart';
import '../../domain/models/responses/database_response.dart';

import '../../domain/models/requests/enterprise_config_request.dart';
import '../../domain/models/responses/enterprise_config_response.dart';

import '../../domain/models/requests/reason_request.dart';
import '../../domain/models/responses/reason_response.dart';

import '../../domain/models/requests/transaction_request.dart';
import '../../domain/models/responses/transaction_response.dart';

import '../../domain/models/requests/transaction_summary_request.dart';
import '../../domain/models/responses/transaction_summary_response.dart';

import '../../domain/models/requests/status_request.dart';
import '../../domain/models/responses/status_response.dart';

import '../../domain/models/requests/account_request.dart';
import '../../domain/models/responses/account_response.dart';

import '../../domain/models/requests/prediction_request.dart';
import '../../domain/models/responses/prediction_response.dart';

import '../../domain/models/requests/history_order_saved_request.dart';
import '../../domain/models/responses/history_order_saved_response.dart';

import '../../domain/models/requests/history_order_updated_request.dart';
import '../../domain/models/responses/history_order_updated_response.dart';

import '../../domain/models/requests/client_request.dart';
import '../../domain/models/requests/send_token.dart';

import '../../domain/repositories/api_repository.dart';
import '../datasources/remote/api_service.dart';
import 'base/base_api_repository.dart';

//services
import '../../locator.dart';
import '../../services/workmanager.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/cache/strategy/async_or_cache_strategy.dart';
import '../../../core/cache/strategy/cache_or_async_strategy.dart';

final CacheManager _cacheManager = locator<CacheManager>();
final WorkmanagerService workmanagerService = locator<WorkmanagerService>();

class ApiRepositoryImpl extends BaseApiRepository implements ApiRepository {
  final ApiService _apiService;

  ApiRepositoryImpl(this._apiService);

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Future<DataState<EnterpriseResponse>> getEnterprise({
    required EnterpriseRequest request,
  }) {
    return getStateOf<EnterpriseResponse>(
      request: () => _apiService.getEnterprise(),
    );
  }

  @override
  Future<DataState<EnterpriseConfigResponse>> getConfigEnterprise({
    required EnterpriseConfigRequest request,
  }) {
    return getStateOf<EnterpriseConfigResponse>(
      request: () => _apiService.getConfigEnterprise(),
    );
  }

  @override
  Future<DataState<ReasonResponse>> reasons({
    required ReasonRequest request,
  }) async {
    return await _cacheManager
        .from<DataState<ReasonResponse>>("reasons")
        .withSerializer((result) => DataSuccess(ReasonResponse.fromMap(result)))
        .withAsync(() => getStateOf<ReasonResponse>(
              request: () => _apiService.reasons(),
            ))
        .withStrategy(CacheOrAsyncStrategy())
        .execute();
  }

  @override
  Future<DataState<AccountResponse>> accounts({
    required AccountRequest request,
  }) async {
    return await _cacheManager
        .from<DataState<AccountResponse>>("accounts")
        .withSerializer(
            (result) => DataSuccess(AccountResponse.fromMap(result)))
        .withAsync(() => getStateOf<AccountResponse>(
              request: () => _apiService.accounts(),
            ))
        .withStrategy(CacheOrAsyncStrategy())
        .execute();
  }

  @override
  Future<DataState<LoginResponse>?> login({
    required LoginRequest request,
  }) async {
    try {
      bool isConnected = await checkConnection();

      if (isConnected) {
        return getStateOf<LoginResponse>(
          request: () => _apiService.login(
              username: request.username, password: request.password),
        );
      } else {
        final sendingData = jsonEncode(request.toString());

        await Workmanager().registerOneOffTask(
          '1',
          'login',
          backoffPolicy: BackoffPolicy.linear,
          backoffPolicyDelay: const Duration(seconds: 20),
          inputData: <String, dynamic>{
            'string': 'login',
            'array': sendingData,
          },
        );

        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DataState<LogoutResponse>> logout({
    required LogoutRequest request,
  }) {
    return getStateOf<LogoutResponse>(
      request: () => _apiService.logout(),
    );
  }

  @override
  Future<DataState<WorkResponse>> works({
    required WorkRequest request,
  }) async {
    return await _cacheManager
        .from<DataState<WorkResponse>>("works-${request.id}")
        .withSerializer((result) => DataSuccess(WorkResponse.fromMap(result)))
        .withAsync(() => getStateOf<WorkResponse>(
              request: () => _apiService.works(
                  id: request.id,
                  udid: request.udid,
                  model: request.model,
                  version: request.version,
                  latitude: request.latitude,
                  longitude: request.longitude,
                  date: request.date,
                  from: request.from),
            ))
        .withStrategy(AsyncOrCacheStrategy())
        .execute();
  }

  @override
  Future<DataState<DatabaseResponse>> database({
    required DatabaseRequest request,
  }) {
    return getStateOf<DatabaseResponse>(
      request: () => _apiService.database(path: request.path),
    );
  }

  @override
  Future<DataState<StatusResponse>?> status({
    required StatusRequest request,
  }) {
    return getStateOf<StatusResponse>(
      request: () => _apiService.status(request.workcode, request.status),
    );
  }

  @override
  Future<DataState<TransactionResponse>?> start({
    required TransactionRequest request,
  }) async {
    bool isConnected = await checkConnection();
    if (isConnected) {
      return getStateOf<TransactionResponse>(
        request: () => _apiService.start(request.transaction),
      );
    } else {
      final sendingData = jsonEncode(request.transaction.toString());
      workmanagerService.registerOneOffTask(
        '1',
        'transaction_start',
        {
          'string': 'transaction',
          'array': sendingData,
        },
      );
      return null;
    }
  }

  @override
  Future<DataState<TransactionResponse>?> arrived({
    required TransactionRequest request,
  }) async {
    bool isConnected = await checkConnection();
    if (isConnected) {
      return getStateOf<TransactionResponse>(
        request: () => _apiService.arrived(request.transaction),
      );
    } else {
      final sendingData = jsonEncode(request.transaction.toString());
      workmanagerService.registerOneOffTask(
        '1',
        'transaction_start',
        {
          'string': 'transaction',
          'array': sendingData,
        },
      );
      return null;
    }
  }

  @override
  Future<DataState<TransactionResponse>?> summary({
    required TransactionRequest request,
  }) async {
    bool isConnected = await checkConnection();
    if (isConnected) {
      return getStateOf<TransactionResponse>(
        request: () => _apiService.summary(request.transaction),
      );
    } else {
      final sendingData = jsonEncode(request.transaction.toString());
      workmanagerService.registerOneOffTask(
        '1',
        'transaction_start',
        {
          'string': 'transaction',
          'array': sendingData,
        },
      );
      return null;
    }
  }

  @override
  Future<DataState<TransactionResponse>?> index({
    required TransactionRequest request,
  }) async {
    try {
      bool isConnected = await checkConnection();
      if (isConnected) {
        return getStateOf<TransactionResponse>(
          request: () => _apiService.index(request.transaction),
        );
      } else {
        final sendingData = jsonEncode(request.transaction.toString());
        workmanagerService.registerOneOffTask(
          '1',
          'transaction',
          {
            'string': 'transaction',
            'array': sendingData,
          },
        );
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DataState<TransactionResponse>?> transaction({
    required TransactionSummaryRequest request,
  }) async {
    try {
      bool isConnected = await checkConnection();
      if (isConnected) {
        return getStateOf<TransactionResponse>(
          request: () => _apiService.transaction(request.transactionSummary),
        );
      } else {
        final sendingData = jsonEncode(request.transactionSummary.toString());
        workmanagerService.registerOneOffTask(
          '1',
          'transaction',
          {
            'string': 'transaction',
            'array': sendingData,
          },
        );
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DataState<TransactionSummaryResponse>?> product({
    required TransactionSummaryRequest request,
  }) async {
    try {
      bool isConnected = await checkConnection();
      if (isConnected) {
        return getStateOf<TransactionSummaryResponse>(
          request: () => _apiService.product(request.transactionSummary)
        );
      } else {
        final sendingData = jsonEncode(request.transactionSummary.toString());
        workmanagerService.registerOneOffTask(
          '1',
          'transaction',
          {
            'string': 'transaction',
            'array': sendingData,
          },
        );
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DataState<StatusResponse>> georeference({
    required ClientRequest request,
  }) {
    return getStateOf<StatusResponse>(
      request: () => _apiService.georeference(request.client),
    );
  }

  @override
  Future<DataState<StatusResponse>> sendFCMToken({
    required SendTokenRequest request,
  }) {
    return getStateOf<StatusResponse>(
      request: () =>
          _apiService.sendFCMToken(request.user_id, request.fcm_token),
    );
  }

  @override
  Future<DataState<PredictionResponse>> prediction({
    required PredictionRequest request,
  }) {
    return getStateOf<PredictionResponse>(
      request: () => _apiService.prediction(request),
    );
  }

  @override
  Future<DataState<HistoryOrderSavedResponse>> historyOrderSaved({
    required HistoryOrderSavedRequest request,
  }) {
    return getStateOf<HistoryOrderSavedResponse>(
      request: () => _apiService.historyOrderSave(request),
    );
  }

  @override
  Future<DataState<HistoryOrderUpdatedResponse>> historyOrderUpdated({
    required HistoryOrderUpdatedRequest request,
  }) {
    return getStateOf<HistoryOrderUpdatedResponse>(
      request: () => _apiService.historyOrderUpdate(request),
    );
  }

  @override
  Future<DataState<RoutingResponse>> routing({
    required RoutingRequest request,
  }) {
    return getStateOf<RoutingResponse>(
      request: () => _apiService.routing(request),
    );
  }

  @override
  Future<DataState<StatusResponse>?> locations({
    required LocationsRequest request,
  }) async {
    bool isConnected = await checkConnection();
    if (isConnected) {
      return getStateOf<StatusResponse>(
        request: () => _apiService.locations(request),
      );
    } else {
      final sendingData = jsonEncode(request);
      workmanagerService.registerOneOffTask(
        '1',
        'store_locations',
        {
          'string': 'store_locations',
          'array': sendingData,
        },
      );
      return null;
    }

  }

  @override
  Future<DataState<StatusResponse>> reason({
    required ReasonMRequest request,
  }) {
    return getStateOf<StatusResponse>(
      request: () => _apiService.news(request.news),
    );
  }
}
