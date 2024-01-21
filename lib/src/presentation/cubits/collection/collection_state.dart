part of 'collection_cubit.dart';

abstract class CollectionState extends Equatable {
  final double? totalSummary;
  final EnterpriseConfig? enterpriseConfig;
  final bool? validate;
  final Work? work;
  final String? error;
  final CollectionState? state;

  const CollectionState(
      {this.enterpriseConfig,
      this.totalSummary,
      this.work,
      this.validate,
      this.state,
      this.error});

  @override
  List<Object?> get props =>
      [totalSummary, enterpriseConfig, validate, work, error];
}

class CollectionInitial extends CollectionState {
  const CollectionInitial({super.totalSummary, super.enterpriseConfig});
}

class CollectionEditingPayment extends CollectionState {
  const CollectionEditingPayment({super.totalSummary, super.enterpriseConfig});
}

class CollectionModalOpen extends CollectionState {
  const CollectionModalOpen({super.totalSummary, super.enterpriseConfig});
}

class CollectionModalClosed extends CollectionState {
  const CollectionModalClosed({super.totalSummary, super.enterpriseConfig});
}

class CollectionLoading extends CollectionState {
  const CollectionLoading({super.totalSummary, super.enterpriseConfig});
}

class CollectionWaiting extends CollectionState {
  const CollectionWaiting({super.totalSummary, super.enterpriseConfig});
}

class CollectionSuccess extends CollectionState {
  const CollectionSuccess({super.work, super.validate});
}

class CollectionFailed extends CollectionState {
  const CollectionFailed(
      {super.totalSummary, super.enterpriseConfig, super.error});
}
