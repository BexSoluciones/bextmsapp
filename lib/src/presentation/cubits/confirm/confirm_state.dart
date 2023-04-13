part of 'confirm_cubit.dart';

abstract class ConfirmState extends Equatable {

  final Work? work;
  final String? error;

  const ConfirmState({
    this.work,
    this.error
  });

  @override
  List<Object?> get props => [work, error];
}

class ConfirmLoading extends ConfirmState {
  const ConfirmLoading();
}

class ConfirmSuccess extends ConfirmState {
  const ConfirmSuccess({super.work});
}

class ConfirmFailed extends ConfirmState {
  const ConfirmFailed({super.error});
}
