import 'dart:io' show HttpStatus;

import 'package:dio/dio.dart';
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
        throw DioError(
          response: httpResponse,
          requestOptions: httpResponse.requestOptions,
        );
      }
    } on DioError catch (error) {
      final errorMessage = DioExceptions.fromDioError(error).toString();
      return DataFailed(errorMessage);
    }
  }
}