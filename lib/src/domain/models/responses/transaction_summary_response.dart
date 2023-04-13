import 'package:equatable/equatable.dart';

import '../transaction_summary.dart';

class TransactionSummaryResponse extends Equatable {
  final TransactionSummary transactionSummary;

  const TransactionSummaryResponse({
    required this.transactionSummary,
  });

  factory TransactionSummaryResponse.fromMap(Map<String, dynamic> map) {
    return TransactionSummaryResponse(
      transactionSummary: TransactionSummary.fromJson(map),
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [transactionSummary];
}