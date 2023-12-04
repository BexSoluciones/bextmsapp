part of 'transaction_cubit.dart';

abstract class TransactionState extends Equatable {
  final List<Transaction> transactions;
  final String? error;

  const TransactionState({
    this.transactions = const [],
    this.error
  });

  @override
  List<Object?> get props => [transactions, error];
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionSuccess extends TransactionState {
  const TransactionSuccess({super.transactions});
}

class TransactionFailed extends TransactionState {
  const TransactionFailed({super.error});
}
