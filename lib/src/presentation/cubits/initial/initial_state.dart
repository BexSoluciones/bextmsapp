part of 'initial_cubit.dart';

abstract class InitialState extends Equatable {
  final Enterprise? enterprise;
  final String? error;

  const InitialState({
    this.enterprise,
    this.error,
  });

  @override
  List<Object?> get props => [enterprise, error];
}

class InitialLoading extends InitialState {
  const InitialLoading();
}

class InitialSuccess extends InitialState {
  const InitialSuccess({super.enterprise});
}

class InitialFailed extends InitialState {
  const InitialFailed({super.error});
}