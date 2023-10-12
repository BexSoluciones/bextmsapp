part of 'work_type_cubit.dart';


@immutable
abstract class WorkTypeState  extends Equatable {

  final WorkTypes? workTypes;
  final String? error;


  const WorkTypeState({
    this.workTypes,
    this.error
  });

  @override
  List<Object?> get props => [
    workTypes,
    error
  ];

}

class WorkTypeCubitLoading extends WorkTypeState {
  const WorkTypeCubitLoading();
}

class WorkTypeCubitSuccess extends WorkTypeState {
  const WorkTypeCubitSuccess({WorkTypes? workTypes}):super(workTypes: workTypes);
}

class WorkTypeCubitFailed extends WorkTypeState{
  const WorkTypeCubitFailed({String? error}) : super(error: error);
}





