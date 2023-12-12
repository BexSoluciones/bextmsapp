part of 'collection_cubit.dart';

abstract class CollectionState extends Equatable {
  final double? totalSummary;
  final EnterpriseConfig? enterpriseConfig;
  final bool? validate;
  final Work? work;
  final String? error;

  const CollectionState(
      {this.enterpriseConfig,
      this.totalSummary,
      this.work,
      this.validate,
      this.error});

  @override
  List<Object?> get props =>
      [totalSummary, enterpriseConfig, validate, work, error];
}

class CollectionInitial extends CollectionState {
  const CollectionInitial({super.totalSummary, super.enterpriseConfig});
}

class CollectionChangeTotal extends CollectionState {
  final double? total;

  const CollectionChangeTotal(this.total);
}

class CollectionLoading extends CollectionState {
  const CollectionLoading();
}

class CollectionWaiting extends CollectionState {
  const CollectionWaiting();
}

class CollectionSuccess extends CollectionState {
  const CollectionSuccess({super.work, super.validate});
}

class CollectionFailed extends CollectionState {
  const CollectionFailed({super.totalSummary, super.enterpriseConfig, super.error});
}
