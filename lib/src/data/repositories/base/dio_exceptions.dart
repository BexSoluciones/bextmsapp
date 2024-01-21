import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  late String message;

  DioExceptions.fromDioError(DioException dioError, String? model) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          model,
          dioError.response?.data
        );
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioExceptionType.unknown:
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
            return 'Huy! Algo salió mal';
          case '':
            return 'Huy! Algo salió mal';
          case 'export database disable':
             return 'No tienes permisos para enviar la base de datos por favor contactate con el administrador';
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
            return 'Huy! Algo salió mal';
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