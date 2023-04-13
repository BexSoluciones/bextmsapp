part of 'summary_cubit.dart';

abstract class SummaryState extends Equatable {
  final List<Summary> summaries;
  final String? origin;
  final String? time;
  final bool isArrived;
  final bool isGeoreference;

  const SummaryState(
      {this.summaries = const [],
      this.origin,
      this.time,
      this.isArrived = true,
      this.isGeoreference = false});

  @override
  List<Object?> get props =>
      [summaries, origin, time, isArrived, isGeoreference];
}

class SummaryLoading extends SummaryState {
  const SummaryLoading();
}

class SummarySuccess extends SummaryState {
  const SummarySuccess(
      {super.summaries,
      super.origin,
      super.time,
      super.isArrived,
      super.isGeoreference});
}
