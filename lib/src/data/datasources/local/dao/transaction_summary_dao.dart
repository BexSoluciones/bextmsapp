part of '../app_database.dart';

class TransactionSummaryDao {
  final AppDatabase _appDatabase;

  TransactionSummaryDao(this._appDatabase);

  List<TransactionSummary> parseTransactionSummaries(List<Map<String, dynamic>> transactionSummaryList) {
    final transactionSummaries = <TransactionSummary>[];
    for (var transactionSummaryMap in transactionSummaryList) {
      final transactionSummary = TransactionSummary.fromJson(transactionSummaryMap);
      transactionSummaries.add(transactionSummary);
    }
    return transactionSummaries;
  }

  Future<List<TransactionSummary>> getAllTransactionSummaries() async {
    final db = await _appDatabase.database;
    final transactionSummaryList = await db!.query(tableTransactionSummaries);
    final transactionSummaries = parseTransactionSummaries(transactionSummaryList);
    return transactionSummaries;
  }

  Future<int> insertTransactionSummary(TransactionSummary transactionSummary) {
    return _appDatabase.insert(tableTransactionSummaries, transactionSummary.toJson());
  }

  Future<int> updateTransactionSummary(TransactionSummary transactionSummary) {
    return _appDatabase.update(tableTransactionSummaries, transactionSummary.toJson(), 'id', transactionSummary.id!);
  }

  Future<void> insertTransactionSummarys(List<TransactionSummary> transactionSummaries) async {
    final db = await _appDatabase.database;
    var batch = db!.batch();
    for (var transactionSummary in transactionSummaries) {
      batch.insert(tableTransactionSummaries, transactionSummary.toJson());
    }
    await batch.commit(noResult: true);
    return Future.value();
  }

  Future<void> emptyTransactionSummaries() async {
    final db = await _appDatabase.database;
    await db!.delete(tableTransactionSummaries, where: 'id > 0');
    return Future.value();
  }
}
