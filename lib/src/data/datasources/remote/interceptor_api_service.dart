import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

//core
import '../../../../core/helpers/index.dart';
//utils
import '../../../utils/constants/strings.dart';
//services
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/logger.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
const String appToken = 'token';

class Logging extends Interceptor {
  Logging({
    required this.dio,
  });

  final Dio dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('REQUEST[${options.method}] => PATH: ${options.path}');
    }
    try {
      var token = _storageService.getString(appToken) ?? '';
      options.headers['Authorization'] = 'Bearer $token';
      options.headers[HttpHeaders.contentTypeHeader] = 'application/json';
      options.headers[HttpHeaders.acceptHeader] = 'application/json';
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      );
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetryOnHttpException(err)) {
      try {
        final helperFunctions = HelperFunctions();
        logDebug(headerDeveloperLogger, 'retry login');
        await helperFunctions.login();
      } catch (e, stackTrace) {
        handler.next(err);
        await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
    } else {
      handler.next(err);
    }
  }

  bool _shouldRetryOnHttpException(DioException err) {
    return err.type == DioExceptionType.badResponse &&
        err.message!.contains('401') &&
        !err.requestOptions.path.contains('auth');
  }
}
