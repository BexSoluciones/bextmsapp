part of 'respawn_cubit.dart';

abstract class RespawnState extends Equatable {
  final String? error;

  const RespawnState({
    this.error,
  });

  @override
  List<Object?> get props => [error];
}

class RespawnLoading extends RespawnState {
  const RespawnLoading();
}

class RespawnSuccess extends RespawnState {
  const RespawnSuccess();
}

class RespawnFailed extends RespawnState {
  const RespawnFailed({super.error});
}