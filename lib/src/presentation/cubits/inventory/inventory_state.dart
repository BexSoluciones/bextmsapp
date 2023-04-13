part of 'inventory_cubit.dart';

class InventoryState extends Equatable {
  final List<Summary> summaries;
  final double? totalSummaries;
  final EnterpriseConfig? enterpriseConfig;
  final bool? isArrived;
  final bool? isPartial;
  final bool? isRejected;
  final String? error;

  const InventoryState(
      {this.summaries = const [],
      this.totalSummaries,
      this.isArrived,
      this.isPartial,
      this.isRejected,
      this.enterpriseConfig,
      this.error});

  @override
  List<Object?> get props => [
        summaries,
        totalSummaries,
        isArrived,
        isPartial,
        isRejected,
        enterpriseConfig,
        error
      ];

  InventoryState copyWith(
      List<Summary>? summaries,
      double? totalSummaries,
      bool? isArrived,
      bool? isPartial,
      bool? isRejected,
      EnterpriseConfig? enterpriseConfig) {
    return InventoryState(
        summaries: summaries ?? this.summaries,
        totalSummaries: totalSummaries ?? this.totalSummaries,
        isArrived: isArrived ?? this.isArrived,
        isRejected: isRejected ?? this.isRejected,
        enterpriseConfig: enterpriseConfig ?? this.enterpriseConfig);
  }
}

class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

class InventorySuccess extends InventoryState {
  const InventorySuccess(
      {super.summaries,
      super.totalSummaries,
      super.isArrived,
      super.isPartial,
      super.isRejected,
      super.enterpriseConfig});
}

class InventoryFailed extends InventoryState {
  const InventoryFailed({ super.error });
}
