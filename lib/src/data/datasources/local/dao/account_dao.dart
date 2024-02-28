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
    final db = await _appDatabase.database;
    final accountList = await db!.query(tableAccount);
    final accounts = parseAccounts(accountList);
    return accounts;
  }

  Stream<List<Account>> watchAllAccounts() async* {
    final db = await _appDatabase.database;
    final accountList = await db!.query(tableAccount);
    final accounts = parseAccounts(accountList);
    yield accounts;
  }

  Future<int> insertAccount(Account account) {
    return _appDatabase.insert(tableAccount, account.toJson());
  }

  Future<void> insertAccounts(List<Account> accounts) async {
    final db = await _appDatabase.database;
    var batch = db!.batch();
    if (accounts.isNotEmpty) {
      await Future.forEach(accounts, (account) async {
        var d = await db.query(tableAccount, where: 'account_id = ?', whereArgs: [account.accountId]);
        var w = parseAccounts(d);
        if (w.isEmpty) {
          batch.insert(tableAccount, account.toJson());
        } else {
          batch.update(tableAccount, account.toJson(), where: 'account_id = ?', whereArgs: [account.accountId]);
        }
      });
    }
    await batch.commit(noResult: true);
    return Future.value();
  }

  Future<int> updateAccount(Account account) {
    return _appDatabase.update(
        tableAccount, account.toJson(), 'id', account.id!);
  }

  Future<void> emptyAccounts() async {
    final db = await _appDatabase.database;
    await db!.delete(tableAccount);
    return Future.value();
  }
}
