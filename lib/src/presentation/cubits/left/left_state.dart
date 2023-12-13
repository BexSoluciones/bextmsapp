part of 'left_cubit.dart';


@immutable
abstract class LeftState   extends Equatable {

  final int? count;
  final String? error;


  const LeftState ({
    this.count,
    this.error
  });

  @override
  List<Object?> get props => [
    count,
    error
  ];

}

class  LeftLoading extends  LeftState  {
  const LeftLoading();
}

class  LeftSuccess extends  LeftState {
  const   LeftSuccess({int? count}):super(count: count);
}

class   LeftFailed extends  LeftState {
  const  LeftFailed({String? error}) : super(error: error);
}
