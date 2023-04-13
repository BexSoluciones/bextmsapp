import 'package:equatable/equatable.dart';

import '../login.dart';

class LoginResponse extends Equatable {
  final Login login;

  const LoginResponse({
    required this.login,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> map) {
    return LoginResponse(
      login: Login.fromMap(map),
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [login];
}