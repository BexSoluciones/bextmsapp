import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  late String message;

  DioExceptions.fromDioError(DioError dioError, String? model) {
    switch (dioError.type) {
      case DioErrorType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioErrorType.connectionTimeout:
        message = "Connection timeout with API server";
        break;
      case DioErrorType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioErrorType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          model,
          dioError.response?.data
        );
        break;
      case DioErrorType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioErrorType.unknown:
        if (dioError.message != null && dioError.message!.contains("SocketException")) {
          message = 'No Internet';
          break;
        }
        message = "Unexpected error occurred";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  String _handleError(int? statusCode, String? model, dynamic error) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        switch (error['error']){
          case null:
            return 'Oops something went wrong';
          case '':
            return 'Oops something went wrong';
          case 'max_udids_used':
            return 'Limite de dispositivos alcanzados 🙁🙁 ($model)';
          case 'Udid disabled':
            return 'Actualmente te encuentras inactivo desde este dispositivo 🙁🙁 ($model)';
          case 'the_user_has_device':
            return 'El dispositivo con que intentas ingresas ya tiene una sesión con un transportador diferente 🙁🙁 ($model)';
          case 'Unauthorised':
            return 'Usuario o contraseña incorrecta 🙁🙁 ($model)';
          case 'Invalid subdomain':
            return 'No trabajas en esta empresa 🙁🙁 ($model)';
          case 'Inactive user':
            return 'El usuario no se encuentra activo 🙁🙁 ($model)';
          default:
            return 'Oops something went wrong';
        }
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message;
}