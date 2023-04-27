import 'dart:io';
import 'package:dio/dio.dart';

//models
import '../../../domain/models/login.dart';
import '../../../domain/models/enterprise.dart';
import '../../../domain/models/enterprise_config.dart';
import '../../../domain/models/work.dart';
import '../../../domain/models/reason.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/transaction_summary.dart';

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

  Future<Response<DatabaseResponse>> database({path}) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final data = <String, dynamic>{'path': path};

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final result = await dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<DatabaseResponse>>(Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/database/send',
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

  Future<Response<TransactionResponse>> start(Transaction transaction) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{
      r'work_id': transaction.workId,
      r'workcode': transaction.workcode,
      r'status': transaction.status,
      r'start': transaction.start,
      r'end': transaction.end,
      r'latitude': transaction.latitude,
      r'longitude': transaction.longitude,
    };

    data.removeWhere((k, v) => v == null);

    final result = await dio.fetch(_setStreamType<Response<TransactionResponse>>(
        Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/transactions/client',
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

  Future<Response<TransactionResponse>> arrived(Transaction transaction) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{
      r'work_id': transaction.workId,
      r'workcode': transaction.workcode,
      r'status': transaction.status,
      r'start': transaction.start,
      r'end': transaction.end,
      r'latitude': transaction.latitude,
      r'longitude': transaction.longitude,
    };

    data.removeWhere((k, v) => v == null);

    final result = await dio.fetch(_setStreamType<Response<TransactionResponse>>(
        Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/transactions/arrived',
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

  Future<Response<TransactionResponse>> summary(Transaction transaction) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = <String, dynamic>{
      r'work_id': transaction.workId,
      r'workcode': transaction.workcode,
      r'summary_id': transaction.summaryId,
      r'order_number': transaction.orderNumber,
      r'status': transaction.status,
      r'start': transaction.start,
      r'end': transaction.end,
      r'latitude': transaction.latitude,
      r'longitude': transaction.longitude,
    };

    data.removeWhere((k, v) => v == null);

    final result = await dio.fetch(_setStreamType<Response<TransactionResponse>>(
        Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/transactions/summary',
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

  Future<Response<TransactionResponse>> index(Transaction transaction) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);

    final headers = <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final data = transaction.toJson();

    final result = await dio.fetch(_setStreamType<Response<TransactionResponse>>(
        Options(
      method: 'POST',
      headers: headers,
      extra: extra,
    )
            .compose(dio.options, '/works/transactions/store',
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

  Future<Response<TransactionResponse>> transaction(TransactionSummary transactionSummary) async {
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

    final result = await dio.fetch(_setStreamType<Response<TransactionResponse>>(
        Options(
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

  Future<Response<TransactionSummaryResponse>> product(TransactionSummary transactionSummary) async {
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

    final result = await dio.fetch(_setStreamType<Response<TransactionSummaryResponse>>(
        Options(
          method: 'POST',
          headers: headers,
          extra: extra,
        )
            .compose(dio.options, '/works/transactions/work-sumaries',
            queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: url ?? dio.options.baseUrl)));

    final value =
    TransactionSummaryResponse(transactionSummary: TransactionSummary.fromJson(result.data!));

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
