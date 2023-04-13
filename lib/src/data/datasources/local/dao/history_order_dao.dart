part of '../app_database.dart';

class HistoryOrderDao {
  final AppDatabase _appDatabase;

  HistoryOrderDao(this._appDatabase);

  List<HistoryOrder> parseHistories(List<Map<String, dynamic>> historyList) {
    final histories = <HistoryOrder>[];
    for (var historyMap in historyList) {
      final history = HistoryOrder.fromJson(historyMap);
      histories.add(history);
    }
    return histories;
  }

  Future<List<HistoryOrder>> getAllLocations() async {
    final db = await _appDatabase.streamDatabase;
    final historyList = await db!.query(tableHistoryOrders);
    final histories = parseHistories(historyList);
    return histories;
  }

  Future<int> insertHistory(HistoryOrder history) {
    return _appDatabase.insert(tableHistoryOrders, history.toJson());
  }

  Future<int> updateHistory(HistoryOrder history) {
    return _appDatabase.update(
        tableHistoryOrders, history.toJson(), 'id', history.id!);
  }

  Future<void> emptyHistories() async {
    final db = await _appDatabase.streamDatabase;
    await db!.delete(tableHistoryOrders, where: 'id > 0');
    return Future.value();
  }
}











