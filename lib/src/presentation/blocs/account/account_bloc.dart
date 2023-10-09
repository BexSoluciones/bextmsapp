import 'dart:async';

import 'package:bexdeliveries/src/domain/models/account.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
          formattedAccountList.insert(0, 'Seleccionar cuenta');
          emit(AccountLoadedState(formattedAccountList));
        } catch (e) {
          emit(AccountErrorState('Error loading accounts: $e'));
        }
      }
    });
  }
}

