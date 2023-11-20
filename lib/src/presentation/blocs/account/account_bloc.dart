import 'dart:async';

import 'package:bexdeliveries/src/domain/models/account.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';

import '../../../domain/repositories/database_repository.dart';

part 'account_event.dart';
part 'account_state.dart';





class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final DatabaseRepository _databaseRepository;

  AccountBloc(this._databaseRepository) : super(AccountLoadingState()) {
    on<LoadAccountListEvent>((event, emit) async {
      if (event is LoadAccountListEvent) {
        emit(AccountLoadingState());
        try {
          final accountList = await _databaseRepository.getAllAccounts();
          final formattedAccountList = accountList.map((account) =>
          '${account.name} - ${account.accountNumber} - (${account.idAccount})')
              .toList();
          final account = await _databaseRepository.getAllAccounts();
          formattedAccountList.insert(0, 'Seleccionar cuenta');
          emit(AccountLoadedState(formattedAccountList,account));
        } catch (e, stackTrace) {
          emit(AccountErrorState('Error loading accounts: $e'));
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
        }
      }
    });
  }
}

