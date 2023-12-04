import 'user.dart';
import 'package:equatable/equatable.dart';

class Login extends Equatable {

  final User? user;
  final String? token;

  const Login({
    required this.user,
    required this.token,
  });

  factory Login.fromMap(Map<String, dynamic> map) {
    return Login(
      user : map['user'] != null ? User.fromJson(map['user']) : null,
      token : map['token'] != null ? map['token'] as String : null,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [user, token];
}
