part of '../app_database.dart';

class AccountDao {
  final AppDatabase _appDatabase;

  AccountDao(this._appDatabase);

  List<Account> parseAccounts(List<Map<String, dynamic>> accountList) {
    final accounts = <Account>[];
    for (var accountMap in accountList) {
      final account = Account.fromJson(accountMap);
      accounts.add(account);
    }
    return accounts;
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await _appDatabase.streamDatabase;
    final accountList = await db!.query(tableAccount);
    final accounts = parseAccounts(accountList);
    return accounts;
  }

  Stream<List<Account>> watchAllAccounts() async* {
    final db = await _appDatabase.streamDatabase;
    final accountList = await db!.query(tableAccount);
    final accounts = parseAccounts(accountList);
    yield accounts;
  }

  Future<int> insertAccount(Account account) {
    return _appDatabase.insert(tableAccount, account.toJson());
  }

  Future<int> updateAccount(Account account) {
    return _appDatabase.update(
        tableAccount, account.toJson(), 'id', account.id!);
  }

  Future<void> emptyAccounts() async {
    final db = await _appDatabase.streamDatabase;
    await db!.delete(tableAccount);
    return Future.value();
  }
}
