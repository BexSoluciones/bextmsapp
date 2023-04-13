part of 'general_cubit.dart';

class GeneralState extends Equatable {
  final String? currentStore;
  final String? error;

  const GeneralState({this.currentStore, this.error});

  @override
  List<Object?> get props => [currentStore, error];
}

class GeneralLoading extends GeneralState {
  const GeneralLoading();
}

class GeneralSuccess extends GeneralState {
  const GeneralSuccess({super.currentStore});
}

class GeneralFailed extends GeneralState {
  const GeneralFailed({super.error});
}
