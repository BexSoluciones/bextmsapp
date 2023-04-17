part of 'history_order_bloc.dart';

@immutable
abstract class HistoryOrderEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class HistoryOrderInitialRequest extends HistoryOrderEvent {
  HistoryOrderInitialRequest(
      { required this.work,
        required this.context});

  final Work work;
  final BuildContext context;
//final int likelihood;
}

class ChangeCurrentWork extends HistoryOrderEvent {
  ChangeCurrentWork({required this.newWorks, required this.work});
  final Work work;
  final List<Work> newWorks;
}
