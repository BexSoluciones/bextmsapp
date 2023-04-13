part of 'login_cubit.dart';

abstract class LoginState extends Equatable {
  final Login? login;
  final Enterprise? enterprise;
  final String? error;

  const LoginState({
    this.login,
    this.enterprise,
    this.error,
  });

  @override
  List<Object?> get props => [login, enterprise, error];
}

class LoginLoading extends LoginState {
  const LoginLoading({super.enterprise});
}

class LoginSuccess extends LoginState {
  const LoginSuccess({super.login, super.enterprise});
}

class LoginFailed extends LoginState {
  const LoginFailed({super.error, super.enterprise});
}