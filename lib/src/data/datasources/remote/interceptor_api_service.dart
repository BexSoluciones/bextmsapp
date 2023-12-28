import 'dart:io';
import 'package:bexdeliveries/src/presentation/cubits/home/home_cubit.dart';
import 'package:bexdeliveries/src/services/logger.dart';
import 'package:bexdeliveries/src/utils/constants/strings.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

//services
import '../../../locator.dart';
import '../../../services/storage.dart';

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
    logDebug(headerDeveloperLogger, 'init error');
    logDebug(headerDeveloperLogger, err.type.toString());
    logDebug(headerDeveloperLogger, err.error.toString());
    logDebug(headerDeveloperLogger, err.message.toString());
    if (_shouldRetryOnHttpException(err)) {
      try {
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
        err.message!.contains('401');
  }
}
