part of 'account_bloc.dart';


abstract class AccountState {}

class AccountLoadingState extends AccountState {}

class AccountLoadedState extends AccountState {
  final List<String> formattedAccountList;
  final List<Account> accounts;


  AccountLoadedState(this.formattedAccountList, this.accounts);
}

class AccountErrorState extends AccountState {
  final String error;

  AccountErrorState(this.error);
}
