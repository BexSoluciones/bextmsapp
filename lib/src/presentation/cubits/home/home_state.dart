part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  final List<Work> works;
  final User? user;
  final String? error;

  const HomeState({
    this.works = const [],
    this.user,
    this.error
  });

  @override
  List<Object?> get props => [works, user, error];
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeSuccess extends HomeState {
  const HomeSuccess({super.works, super.user});
}

class HomeFailed extends HomeState {
  const HomeFailed({super.error, super.user});
}

class UpdateUser extends HomeState {
  final User user;

  const UpdateUser(this.user);
}
