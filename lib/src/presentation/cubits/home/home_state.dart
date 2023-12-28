part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

extension HomeStateX on HomeStatus {
  bool get isInitial => this == HomeStatus.initial;
  bool get isLoading => this == HomeStatus.loading;
  bool get isSuccess => this == HomeStatus.success;
  bool get isError => this == HomeStatus.failure;
}

class HomeState extends Equatable {
  final HomeStatus? status;
  final List<Work> works;
  final User? user;
  final String? error;

  const HomeState({
    this.status,
    this.works = const [],
    this.user,
    this.error
  });

  @override
  List<Object?> get props => [status, works, user, error];

  HomeState copyWith({
    HomeStatus? status,
    List<Work>? works,
    User? user,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      works: works ?? this.works,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

