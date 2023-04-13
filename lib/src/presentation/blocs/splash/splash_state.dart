part of 'splash_bloc.dart';

abstract class SplashScreenState extends Equatable {
  final String? route;

  const SplashScreenState({this.route});

  @override
  List<Object?> get props => [route];
}

class Initial extends SplashScreenState {}

class Loading extends SplashScreenState {}

class Loaded extends SplashScreenState {
  const Loaded({super.route});
}