part of 'history_order_bloc.dart';

@immutable
abstract class HistoryOrderEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class HistoryOrderStart extends HistoryOrderEvent {
  HistoryOrderStart({required this.work, required this.context});

  final Work work;
  final BuildContext context;
}

class HistoryOrderInitialRequest extends HistoryOrderEvent {
  HistoryOrderInitialRequest({required this.work, required this.context});

  final Work work;
  final BuildContext context;
}

class ChangeCurrentWork extends HistoryOrderEvent {
  ChangeCurrentWork({required this.work});
  final Work work;
}
