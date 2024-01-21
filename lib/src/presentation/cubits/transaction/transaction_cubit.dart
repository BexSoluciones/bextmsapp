import 'dart:async';
import 'package:equatable/equatable.dart';

//core
import '../../../../core/helpers/index.dart';

//cubit
import '../base/base_cubit.dart';

//utils

//domain
import '../../../domain/models/transaction.dart';

import '../../../domain/repositories/database_repository.dart';
import '../../../domain/repositories/api_repository.dart';

import '../../../domain/abstracts/format_abstract.dart';


//service
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'transaction_state.dart';

final helperFunctions = HelperFunctions();

class TransactionCubit extends BaseCubit<TransactionState, String?> with FormatDate {
  final DatabaseRepository _databaseRepository;

  TransactionCubit(this._databaseRepository)
      : super(const TransactionLoading(), null);

  Future<void> getAllTransactions() async {
    emit(await _getAllTransactions());
  }

  Future<TransactionState> _getAllTransactions() async {
    final transactions = await _databaseRepository.getAllTransactions();
    return TransactionSuccess(transactions: transactions);
  }

}
