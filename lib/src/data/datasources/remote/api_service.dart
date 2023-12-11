import 'dart:io';
import 'package:bexdeliveries/src/domain/models/requests/locations_request.dart';
import 'package:dio/dio.dart';

//models
import '../../../domain/models/login.dart';
import '../../../domain/models/enterprise.dart';
import '../../../domain/models/client.dart';
import '../../../domain/models/enterprise_config.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/models/work.dart';
import '../../../domain/models/reason.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/transaction_summary.dart';
import '../../../domain/models/account.dart';

//interceptor
import 'interceptor_api_service.dart';

//response
import '../../../domain/models/responses/enterprise_response.dart';
import '../../../domain/models/responses/login_response.dart';
import '../../../domain/models/responses/logout_response.dart';
import '../../../domain/models/responses/work_response.dart';
import '../../../domain/models/responses/database_response.dart';
import '../../../domain/models/responses/enterprise_config_response.dart';
import '../../../domain/models/responses/reason_response.dart';
import '../../../domain/models/responses/transaction_response.dart';
import '../../../domain/models/responses/transaction_summary_response.dart';
import '../../../domain/models/responses/status_response.dart';
import '../../../domain/models/responses/account_response.dart';
import '../../../domain/models/responses/prediction_response.dart';
import '../../../domain/models/responses/history_order_updated_response.dart';
import '../../../domain/models/responses/history_order_saved_response.dart';
import '../../../domain/models/responses/routing_response.dart';

//request
import '../../../domain/models/requests/prediction_request.dart';
import '../../../domain/models/requests/history_order_saved_request.dart';
import '../../../domain/models/requests/history_order_updated_request.dart';
import '../../../domain/models/requests/routing_request.dart';

//services
import '../../../locator.dart';
import '../../../services/storage.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class ApiService {
  late Dio dio;

  String? get url {
    var company = _storageService.getString('company_name');
    if (company == null) return null;
    return 'https://$company.bexdeliveries.com/api/v1';
  }

  ApiService() {
    dio = Dio(
      BaseOptions(
          baseUrl: url ?? 'https://demo.bexdeliveries.com/api/v1',
          connectTimeout: const Duration(seconds: 5000),
          receiveTimeout: const Duration(seconds: 3000),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'}),
    );

    dio.interceptors.add(Logging(dio: dio));
  }

  Future<Response<EnterpriseResponse>> getEnterprise() async {
    const extra = <String, dynamic>{};
    final headers = <String, dynamic>{};
    final data = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final result = await dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<EnterpriseResponse>>(Options(
      method: 'GET',
      headers: headers,
      extra: extra,
    )
            .compose(
              dio.options,
              '/enterprises/show',
              queryParameters: queryParameters,
              data: data,
            )
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));
    final value =
        EnterpriseResponse(enterprise: Enterprise.fromMap(result.data!));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<EnterpriseConfigResponse>> getConfigEnterprise() async {
    const extra = <String, dynamic>{};
    final headers = <String, dynamic>{};
    final data = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final result = await dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<EnterpriseConfigResponse>>(Options(
      method: 'GET',
      headers: headers,
      extra: extra,
    )
            .compose(
              dio.options,
              '/enterprise/config',
              queryParameters: queryParameters,
              data: data,
            )
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));
    final value = EnterpriseConfigResponse(
        enterpriseConfig: EnterpriseConfig.fromMap(result.data!));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<LoginResponse>> login({username, password}) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    final data = <String, dynamic>{
      r'email': username,
      r'password': password,
    };

    data.removeWhere((k, v) => v == null);

    final result = await dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<LoginResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(
              dio.options,
              '/auth/login',
              queryParameters: queryParameters,
              data: data,
            )
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = LoginResponse(login: Login.fromMap(result.data!));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<LogoutResponse>> logout() async {
    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    final result = await dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<LogoutResponse>>(Options(
      method: 'POST',
      headers: headers,
    )
            .compose(
              dio.options,
              '/auth/logout',
            )
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = LogoutResponse(message: result.data!['message']);

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<ReasonResponse>> reasons() async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};

    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result =
        await dio.fetch(_setStreamType<Response<ReasonResponse>>(Options(
      method: 'GET',
      headers: headers,
      extra: extra,
    )
            .compose(
              dio.options,
              '/works/transactions/reasons',
              queryParameters: queryParameters,
            )
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = ReasonResponse(
        reasons: List<Reason>.from(
            result.data.map((e) => Reason.fromJson(e)).toList()));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<AccountResponse>> accounts() async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};

    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result =
        await dio.fetch(_setStreamType<Response<AccountResponse>>(Options(
      method: 'GET',
      headers: headers,
      extra: extra,
    )
            .compose(
              dio.options,
              '/bank-accounts',
              queryParameters: queryParameters,
            )
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = AccountResponse(
        accounts: List<Account>.from(
            result.data.map((e) => Account.fromJson(e)).toList()));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<WorkResponse>> works(
      {id,
      password,
      udid,
      model,
      version,
      latitude,
      longitude,
      date,
      from}) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'id': id,
      r'udid': udid,
      r'model': model,
      r'version': version,
      r'latitude': latitude,
      r'longitude': longitude,
      r'date': date,
      r'from': from
    };
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result =
        await dio.fetch(_setStreamType<Response<WorkResponse>>(Options(
      method: 'GET',
      headers: headers,
      extra: extra,
    )
            .compose(
              dio.options,
              '/works',
              queryParameters: queryParameters,
            )
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = WorkResponse(
        works:
            List<Work>.from(result.data.map((e) => Work.fromJson(e)).toList()));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<DatabaseResponse>> database({path, tableName}) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final data = FormData.fromMap({
      'user_id': _storageService.getInt('user_id'),
      '$tableName': await MultipartFile.fromFile(path, filename: tableName)
    });

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result = await dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<DatabaseResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/database/file',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = DatabaseResponse.fromMap(result.data!);

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<StatusResponse>> status(
      String workcode, String status) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{r'workcode': workcode, r'status': status};

    final result = await dio.fetch(
        _setStreamType<Response<TransactionResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/status',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = StatusResponse.fromMap(result.data!);

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<TransactionResponse>> start(Transaction transaction) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/transactions/client',
                queryParameters: queryParameters, data: transaction.toJson())
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value =
        TransactionResponse(transaction: Transaction.fromJson(result.data!));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<TransactionResponse>> arrived(Transaction transaction) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/transactions/arrived',
                queryParameters: queryParameters, data: transaction.toJson())
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value =
        TransactionResponse(transaction: Transaction.fromJson(result.data!));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<TransactionResponse>> summary(Transaction transaction) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/transactions/summary',
                queryParameters: queryParameters, data: transaction.toJson())
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value =
        TransactionResponse(transaction: Transaction.fromJson(result.data!));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<TransactionResponse>> index(Transaction transaction) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/transactions/store',
                queryParameters: queryParameters, data: transaction.toJson())
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value =
        TransactionResponse(transaction: Transaction.fromJson(result.data!));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<TransactionResponse>> transaction(
      TransactionSummary transactionSummary) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{
      r'work_id': transactionSummary.workId,
      r'order_number': transactionSummary.orderNumber,
    };

    data.removeWhere((k, v) => v == null);

    final result = await dio.fetch(
        _setStreamType<Response<TransactionResponse>>(Options(
      method: 'GET',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/transactions/index',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value =
        TransactionResponse(transaction: Transaction.fromJson(result.data!));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<TransactionSummaryResponse>> product(
      TransactionSummary transactionSummary) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{
      r'transaction_id': transactionSummary.transactionId,
      r'summary_id': transactionSummary.summaryId,
      r'num_items': transactionSummary.numItems,
      r'codmotvis': transactionSummary.codmotvis,
      r'reason': transactionSummary.reason,
      r'product_name': transactionSummary.productName,
    };

    data.removeWhere((k, v) => v == null);

    final result = await dio.fetch(
        _setStreamType<Response<TransactionSummaryResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/transactions/work-sumaries',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = TransactionSummaryResponse(
        transactionSummary: TransactionSummary.fromJson(result.data!));

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<StatusResponse>> georeference(Client client) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionSummaryResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/client/location/save',
                queryParameters: queryParameters, data: client.toJson())
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = StatusResponse.fromMap(result.data!);

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<StatusResponse>> sendFCMToken(
      int idUser, String fmcToken) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{
      'user_id': idUser,
      'fcm_token': fmcToken,
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionSummaryResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/fcm/store',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = StatusResponse.fromMap(result.data!);

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<PredictionResponse>> prediction(
      PredictionRequest request) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{
      'zone_id': request.zoneId,
      'workcode': request.workcode,
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionSummaryResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/history-order/new-prediction',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = PredictionResponse.fromMap(result.data!);

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<HistoryOrderSavedResponse>> historyOrderSave(
      HistoryOrderSavedRequest request) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{
      'work_id': request.workId,
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionSummaryResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/history-order/save',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = HistoryOrderSavedResponse.fromMap(result.data!);

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<HistoryOrderUpdatedResponse>> historyOrderUpdate(
      HistoryOrderUpdatedRequest request) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{
      'count': request.count,
      'workcode': request.workcode,
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionSummaryResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/history-order/use',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = HistoryOrderUpdatedResponse.fromMap(result.data!);

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<RoutingResponse>> routing(RoutingRequest request) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{
      'history_id': request.historyId,
      'workcode': request.workcode,
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionSummaryResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/history-order/new-routing',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = RoutingResponse.fromMap(result.data!);

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }

  Future<Response<StatusResponse>> locations(LocationsRequest request) async {

    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result = await dio.fetch(
        _setStreamType<Response<TransactionSummaryResponse>>(Options(
          method: 'POST',
          headers: headers,
          extra: extra,
        )
            .compose(dio.options, '/location/newlocation',
            queryParameters: queryParameters, data: request.body)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value = StatusResponse.fromMap(result.data!);

    return Response(
        data: value,
        requestOptions: result.requestOptions,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
        isRedirect: result.isRedirect,
        redirects: result.redirects,
        extra: result.extra,
        headers: result.headers);
  }


  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
