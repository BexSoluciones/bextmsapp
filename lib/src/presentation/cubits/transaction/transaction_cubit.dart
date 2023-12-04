import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'package:location_repository/location_repository.dart';
import 'package:equatable/equatable.dart';

//core
import '../../../../core/helpers/index.dart';

//cubit
import '../../blocs/gps/gps_bloc.dart';
import '../base/base_cubit.dart';

//blocs
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//utils
import '../../../utils/resources/data_state.dart';
import '../../../utils/constants/strings.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/summary.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/processing_queue.dart';

import '../../../domain/repositories/database_repository.dart';
import '../../../domain/repositories/api_repository.dart';

import '../../../domain/abstracts/format_abstract.dart';

import '../../../domain/models/requests/login_request.dart';
import '../../../domain/models/requests/work_request.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';
import '../../../services/logger.dart';

part 'transaction_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();
final helperFunctions = HelperFunctions();

class TransactionCubit extends BaseCubit<TransactionState, String?> with FormatDate {
  final ApiRepository _apiRepository;
  final DatabaseRepository _databaseRepository;

  TransactionCubit(this._databaseRepository, this._apiRepository)
      : super(const TransactionLoading(), null);

  Future<void> getAllTransactions() async {
    emit(await _getAllTransactions());
  }

  Future<TransactionState> _getAllTransactions() async {
    final transactions = await _databaseRepository.getAllTransactions();
    return TransactionSuccess(transactions: transactions);
  }

}
