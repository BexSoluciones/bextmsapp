import 'dart:io' show HttpStatus;

import 'package:bexdeliveries/src/services/logger.dart';
import 'package:bexdeliveries/src/utils/constants/strings.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';

import '../../../utils/resources/data_state.dart';
import 'dio_exceptions.dart';

abstract class BaseApiRepository {
  @protected
  Future<DataState<T>> getStateOf<T>({
    required Future<Response<T>> Function() request,
  }) async {
    try {
      final httpResponse = await request();
      if (httpResponse.statusCode == HttpStatus.ok || httpResponse.statusCode == HttpStatus.created) {
        return DataSuccess(httpResponse.data as T);
      } else {
        throw DioException(
          response: httpResponse,
          requestOptions: httpResponse.requestOptions,
        );
      }
    } on DioException catch (error,stackTrace) {
      //TODO:: [Heider Zapa ] resolve model variable in error
      final errorMessage = DioExceptions.fromDioError(error, 'SM-A33G').toString();
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      return DataFailed(errorMessage);
    }
  }
}