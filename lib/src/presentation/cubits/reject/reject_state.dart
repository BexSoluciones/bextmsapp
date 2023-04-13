part of 'reject_cubit.dart';

abstract class RejectState extends Equatable {
  final List<Reason>? reasons;
  final bool? needPhoto;
  final bool? needFirm;
  final bool? needObservation;
  final String? error;

  const RejectState({
    this.reasons,
    this.needFirm,
    this.needPhoto,
    this.needObservation,
    this.error,
  });

  @override
  List<Object?> get props => [reasons, needPhoto, needObservation, needFirm, error];
}

class RejectLoading extends RejectState {
  const RejectLoading();
}

class RejectSuccess extends RejectState {
  const RejectSuccess({super.reasons, super.needFirm, super.needObservation, super.needPhoto});
}

class RejectFailed extends RejectState {
  const RejectFailed({super.reasons, super.error});
}