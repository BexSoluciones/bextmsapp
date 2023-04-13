part of '../app_database.dart';

class TransactionDao {
  final AppDatabase _appDatabase;

  TransactionDao(this._appDatabase);

  List<t.Transaction> parseTransactions(List<Map<String, dynamic>> transactionList) {
    final transactions = <t.Transaction>[];
    for (var transactionMap in transactionList) {
      final transaction = t.Transaction.fromJson(transactionMap);
      transactions.add(transaction);
    }
    return transactions;
  }

  Future<List<t.Transaction>> getAllTransactions() async {
    final db = await _appDatabase.streamDatabase;
    final transactionList = await db!.rawQuery(
        'SELECT *, COUNT(DISTINCT number_customer || code_place) as count FROM ${t.tableTransactions} GROUP BY ${t.TransactionFields.id}');
    return parseTransactions(transactionList);
  }

  Future<String?> getDiffTime(int workId) async {
    final db = await _appDatabase.streamDatabase;

    final transactionsList = await db!.rawQuery(
        'SELECT * FROM transactions WHERE work_id = $workId and status = "arrived" LIMIT 1');

    final transaction = parseTransactions(transactionsList);

    if (transaction.isEmpty) {
      return null;
    }

    var inputSeconds = DateTime.now()
        .difference(DateTime.parse(transaction[0].start!))
        .inSeconds;

    var secondsInAMinute = 60;
    var secondsInAnHour = 60 * secondsInAMinute;
    var secondsInADay = 24 * secondsInAnHour;

    // extract hours
    var hourSeconds = inputSeconds % secondsInADay;
    var hours = (hourSeconds / secondsInAnHour).floor();
    // extract minutes
    var minuteSeconds = hourSeconds % secondsInAnHour;
    var minutes = (minuteSeconds / secondsInAMinute).floor();
    // extract the remaining seconds
    var remainingSeconds = minuteSeconds % secondsInAMinute;
    var seconds = (remainingSeconds).ceil();
    // return the final
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<bool> validateTransaction(int workId) async {
    final db = await _appDatabase.streamDatabase;

    final transactionList = await db!.query(t.tableTransactions,
        where: 'work_id = ? AND status != ? AND status != ? AND status != ?',
        whereArgs: [workId, 'arrived', 'start', 'summary']);

    final summaryList = await db.query(tableSummaries,
        where: 'work_id = ?',
        whereArgs: [workId],
        groupBy: '$tableSummaries.${SummaryFields.orderNumber}');

    return transactionList.isNotEmpty &&
        summaryList.isNotEmpty &&
        (transactionList.length == summaryList.length);
  }

  Future<bool> validateSubTransaction(int workId, String orderNumber) async {
    final db = await _appDatabase.streamDatabase;

    final transactionList = await db!.query(t.tableTransactions,
        where: 'work_id = ? AND order_number = ? AND status != ?',
        whereArgs: [workId, orderNumber, 'summary']);

    return transactionList.isNotEmpty;
  }

  Future<bool> validateTransactionSummary(
      String workcode, String orderNumber, String status) async {
    final db = await _appDatabase.streamDatabase;
    final transactionList = await db!.query(t.tableTransactions,
        where: 'workcode = ? AND order_number = ? AND status = ?',
        whereArgs: [workcode, orderNumber, status]);
    final transactions = parseTransactions(transactionList);
    return transactions.isNotEmpty;
  }

  Future<bool> validateTransactionStart(String workcode, String status) async {
    final db = await _appDatabase.streamDatabase;

    var transactionList = await db!.query(t.tableTransactions,
        where: 'workcode = ? AND status = ?', whereArgs: [workcode, status]);

    return transactionList.isNotEmpty;
  }

  Future<bool> validateTransactionArrived(int workId, String status) async {
    final db = await _appDatabase.streamDatabase;

    final transactionList = await db!.query(t.tableTransactions,
        where: 'work_id = ? AND status = ?', whereArgs: [workId, status]);

    final transactions = parseTransactions(transactionList);
    return transactions.isNotEmpty;
  }

  Stream<bool?> watchTransactionClient(String workcode, String status) async* {
    final db = await _appDatabase.streamDatabase;

    final transactionList = await db!.query(t.tableTransactions,
        where: 'workcode = ? AND status = ?', whereArgs: [workcode, status]);

    yield transactionList.isNotEmpty;
  }

  Future<int> insertTransaction(t.Transaction transaction) {
    return _appDatabase.insert(t.tableTransactions, transaction.toJson());
  }

  Future<int> insertTransactionSummary(TransactionSummary transactionSummary) {
    return _appDatabase.insert(tableTransactionSummaries, transactionSummary.toJson());
  }

  Future<int> updateTransaction(t.Transaction transaction) {
    return _appDatabase.update(t.tableTransactions, transaction.toJson(), 'id', transaction.id!);
  }

  Future<void> insertTransactions(List<t.Transaction> transactions) async {
    final db = await _appDatabase.streamDatabase;

    var batch = db!.batch();

    if (transactions.isNotEmpty) {
      await Future.forEach(transactions, (transaction) async {
        var d = await db.query(t.tableTransactions, where: 'id = ?', whereArgs: [transaction.id]);
        var w = parseTransactions(d);
        if (w.isEmpty) {
          batch.insert(t.tableTransactions, transaction.toJson());
        } else {
          batch.update(t.tableTransactions, transaction.toJson(), where: 'id = ?', whereArgs: [transaction.id]);
        }
      });
    }

    await batch.commit(noResult: true);

    return Future.value();
  }

  Future<void> emptyTransactions() async {
    final db = await _appDatabase.streamDatabase;
    await db!.delete(t.tableTransactions, where: 'id > 0');
    return Future.value();
  }
}