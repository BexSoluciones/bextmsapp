part of 'inventory_cubit.dart';

enum InventoryStatus { initial, loading, success, failed }

class InventoryState extends Equatable {
  final InventoryStatus status;
  final List<Summary> summaries;
  final double? totalSummaries;
  final EnterpriseConfig? enterpriseConfig;
  final bool? isArrived;
  final bool? isPartial;
  final bool? isRejected;
  final double? quantity;
  final String? error;

  const InventoryState(
      {this.status = InventoryStatus.initial,
      this.summaries = const [],
      this.totalSummaries,
      this.isArrived,
      this.isPartial,
      this.isRejected,
      this.quantity,
      this.enterpriseConfig,
      this.error});

  @override
  List<Object?> get props => [
        status,
        summaries,
        totalSummaries,
        isArrived,
        isPartial,
        isRejected,
        quantity,
        enterpriseConfig,
        error
      ];

  InventoryState copyWith({
    InventoryStatus? status,
    List<Summary>? summaries,
    double? totalSummaries,
    bool? isArrived,
    bool? isPartial,
    bool? isRejected,
    double? quantity,
    EnterpriseConfig? enterpriseConfig,
    String? error,
  }) =>
      InventoryState(
          status: status ?? this.status,
          summaries: summaries ?? this.summaries,
          totalSummaries: totalSummaries ?? this.totalSummaries,
          isArrived: isArrived ?? this.isArrived,
          isRejected: isRejected ?? this.isRejected,
          quantity: quantity ?? this.quantity,
          enterpriseConfig: enterpriseConfig ?? this.enterpriseConfig,
          error: error ?? this.error);
}
