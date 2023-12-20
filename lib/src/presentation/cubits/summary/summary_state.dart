part of 'summary_cubit.dart';

abstract class SummaryState extends Equatable {
  final List<Summary> summaries;
  final String? origin;
  final String? time;
  final bool? isArrived;
  final bool? isGeoReference;

  const SummaryState(
      {this.summaries = const [],
      this.origin,
      this.time,
      this.isArrived,
      this.isGeoReference});

  @override
  List<Object?> get props =>
      [summaries, origin, time, isArrived, isGeoReference];
}

class SummaryLoading extends SummaryState {
  const SummaryLoading();
}

class SummaryLoadingMap extends SummaryState {
  const SummaryLoadingMap();
}

class SummarySuccess extends SummaryState {
  const SummarySuccess(
      {super.summaries,
      super.origin,
      super.time,
      super.isArrived,
      super.isGeoReference});
}
