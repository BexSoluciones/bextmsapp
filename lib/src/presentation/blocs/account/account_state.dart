part of 'account_bloc.dart';

abstract class AccountState {}

class AccountLoadingState extends AccountState {}

class AccountLoadedState extends AccountState {
  final List<Account> accounts;
  AccountLoadedState(this.accounts);
}

class AccountErrorState extends AccountState {
  final String error;

  AccountErrorState(this.error);
}
