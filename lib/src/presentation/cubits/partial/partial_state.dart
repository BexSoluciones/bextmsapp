part of 'partial_cubit.dart';

abstract class PartialState extends Equatable {
  final List<Summary>? summaries;
  final List<ReasonProduct>? products;
  final List<Reason>? reasons;
  final String? error;

  const PartialState({
    this.summaries,
    this.products,
    this.reasons,
    this.error,
  });

  @override
  List<Object?> get props => [summaries, products, reasons, error];
}

class PartialLoading extends PartialState {
  const PartialLoading();
}

class PartialSuccess extends PartialState {
  const PartialSuccess({super.summaries, super.products, super.reasons});
}

class PartialFailed extends PartialState {
  const PartialFailed({super.summaries, super.products, super.reasons, super.error});
}