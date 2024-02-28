part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  final String? route;
  final dynamic arguments;
  const SplashState({this.route, this.arguments});

  @override
  List<Object?> get props => [route];
}

class Initial extends SplashState {}

class Loading extends SplashState {}

class Loaded extends SplashState {
  const Loaded({super.route, super.arguments});
}