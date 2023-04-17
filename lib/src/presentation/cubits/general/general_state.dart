part of 'general_cubit.dart';

class GeneralState extends Equatable {
  String? currentStore;
  StreamController<void>? resetController = StreamController.broadcast();
  String? error;

  GeneralState({this.currentStore, this.resetController, this.error});

  @override
  List<Object?> get props => [currentStore, resetController, error];
}

class GeneralLoading extends GeneralState {
  GeneralLoading();
}

class GeneralSuccess extends GeneralState {
  GeneralSuccess({super.currentStore, super.resetController});
}

class GeneralFailed extends GeneralState {
  GeneralFailed({super.error});
}
