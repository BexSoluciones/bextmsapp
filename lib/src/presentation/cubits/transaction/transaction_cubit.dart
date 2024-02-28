import 'dart:async';
import 'package:equatable/equatable.dart';

//core
import '../../../../core/helpers/index.dart';

//cubit
import '../base/base_cubit.dart';

//domain
import '../../../domain/models/transaction.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/abstracts/format_abstract.dart';

part 'transaction_state.dart';

class TransactionCubit extends BaseCubit<TransactionState, String?> with FormatDate {
  final DatabaseRepository databaseRepository;
  final helperFunctions = HelperFunctions();

  TransactionCubit(this.databaseRepository)
      : super(const TransactionLoading(), null);

  Future<void> getAllTransactions() async {
    emit(await _getAllTransactions());
  }

  Future<TransactionState> _getAllTransactions() async {
    final transactions = await databaseRepository.getAllTransactions();
    return TransactionSuccess(transactions: transactions);
  }

}
