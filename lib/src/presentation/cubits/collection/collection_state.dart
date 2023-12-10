part of 'collection_cubit.dart';

abstract class CollectionState extends Equatable {
  final double? totalSummary;
  final EnterpriseConfig? enterpriseConfig;
  final bool? validate;
  final String? error;

  const CollectionState({
    this.enterpriseConfig,
    this.totalSummary,
    this.validate,
    this.error
  });

  @override
  List<Object?> get props => [totalSummary, enterpriseConfig, validate, error];
}

class CollectionInitial extends CollectionState {
  const CollectionInitial({super.totalSummary, super.enterpriseConfig});
}

class CollectionLoading extends CollectionState {
  const CollectionLoading();
}

class CollectionSuccess extends CollectionState {
  final Work? work;
  const CollectionSuccess(this.work, {super.validate, super.totalSummary, super.enterpriseConfig});
}

class CollectionFailed extends CollectionState {
  const CollectionFailed({super.error});
}
