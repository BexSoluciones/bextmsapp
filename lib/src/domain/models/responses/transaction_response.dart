import 'package:equatable/equatable.dart';

import '../transaction.dart';

class TransactionResponse extends Equatable {
  final Transaction transaction;

  const TransactionResponse({
    required this.transaction,
  });

  factory TransactionResponse.fromMap(Map<String, dynamic> map) {
    return TransactionResponse(
      transaction: Transaction.fromJson(map),
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [transaction];
}