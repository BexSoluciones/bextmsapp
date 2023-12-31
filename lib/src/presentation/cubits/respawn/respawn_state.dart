part of 'respawn_cubit.dart';

abstract class RespawnState extends Equatable {
  final List<Reason>? reasons;
  final EnterpriseConfig? enterpriseConfig;
  final bool? needPhoto;
  final bool? needFirm;
  final bool? needObservation;
  final String? error;

  const RespawnState({
    this.reasons,
    this.enterpriseConfig,
    this.needFirm,
    this.needPhoto,
    this.needObservation,
    this.error,
  });

  @override
  List<Object?> get props =>
      [reasons, enterpriseConfig, needPhoto, needObservation, needFirm, error];
}

class RespawnLoading extends RespawnState {
  const RespawnLoading();
}

class RespawnSuccess extends RespawnState {
  const RespawnSuccess(
      {super.reasons,
      super.enterpriseConfig,
      super.needFirm,
      super.needObservation,
      super.needPhoto});
}

class RespawnFailed extends RespawnState {
  const RespawnFailed({super.reasons, super.enterpriseConfig, super.error});
}
