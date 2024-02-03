part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  final String? route;
  const SplashState({this.route});

  @override
  List<Object?> get props => [route];
}

class Initial extends SplashState {}

class Loading extends SplashState {}

class Loaded extends SplashState {
  const Loaded({super.route});
}