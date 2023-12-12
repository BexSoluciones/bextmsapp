part of 'collection_cubit.dart';

class CollectionState extends Equatable {
  final double? totalSummary;
  double? total;
  final EnterpriseConfig? enterpriseConfig;
  final bool? validate;
  final Work? work;
  final String? error;

  CollectionState(
      {this.enterpriseConfig,
      this.total,
      this.totalSummary,
      this.work,
      this.validate,
      this.error});

  CollectionState copyWith(
          {double? totalSummary,
          double? total,
          EnterpriseConfig? enterpriseConfig,
          bool? validate,
          Work? work,
          String? error}) =>
      CollectionState(
        totalSummary: totalSummary ?? this.totalSummary,
        total: total ?? this.total,
        enterpriseConfig: enterpriseConfig ?? this.enterpriseConfig,
        validate: validate ?? this.validate,
        work: work ?? this.work,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props =>
      [totalSummary, enterpriseConfig, validate, work, error];
}

class CollectionInitial extends CollectionState {
  CollectionInitial({super.total, super.totalSummary, super.enterpriseConfig});
}

class CollectionLoading extends CollectionState {
  CollectionLoading();
}

class CollectionWaiting extends CollectionState {
  CollectionWaiting();
}

class CollectionSuccess extends CollectionState {
  CollectionSuccess({super.work, super.validate});
}

class CollectionFailed extends CollectionState {
  CollectionFailed({super.error});
}
