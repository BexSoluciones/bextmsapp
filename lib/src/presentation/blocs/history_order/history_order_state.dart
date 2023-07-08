part of 'history_order_bloc.dart';

@immutable
abstract class HistoryOrderState extends Equatable {
  @override
  List<Object> get props => [];
}

class HistoryOrderLoading extends HistoryOrderState {}

class HistoryOrderShow extends HistoryOrderState {
  HistoryOrderShow({required this.historyOrder});
  final HistoryOrder? historyOrder;
}

class HistoryOrderError extends HistoryOrderState {
  HistoryOrderError({required this.error});
  final String error;
}

class HistoryOrderChangeLoading extends HistoryOrderState {}

class HistoryOrderChanged extends HistoryOrderState {
  HistoryOrderChanged({required this.historyOrder});
  final HistoryOrder? historyOrder;
}

class HistoryOrderInitial extends HistoryOrderState {}
