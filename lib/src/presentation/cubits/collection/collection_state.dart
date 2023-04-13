part of 'collection_cubit.dart';

abstract class CollectionState extends Equatable {

  final double? totalSummary;
  final EnterpriseConfig? enterpriseConfig;
  final String? error;

  const CollectionState({
    this.enterpriseConfig,
    this.totalSummary,
    this.error
  });

  @override
  List<Object?> get props => [totalSummary, enterpriseConfig, error];
}

class CollectionLoading extends CollectionState {
  const CollectionLoading();
}

class CollectionSuccess extends CollectionState {
  const CollectionSuccess({super.totalSummary, super.enterpriseConfig});
}

class CollectionFailed extends CollectionState {
  const CollectionFailed({super.error});
}
