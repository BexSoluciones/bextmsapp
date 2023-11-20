part of 'count_cubit.dart';

@immutable
abstract class CountState   extends Equatable {

  final int? count;
  final String? error;


  const CountState ({
    this.count,
    this.error
  });

  @override
  List<Object?> get props => [
    count,
    error
  ];

}

class  CountLoading extends  CountState  {
  const  CountLoading();
}

class  CountSuccess extends  CountState {
  const  CountSuccess({int? count}):super(count: count);
}

class   CountFailed extends  CountState {
  const  CountFailed({String? error}) : super(error: error);
}