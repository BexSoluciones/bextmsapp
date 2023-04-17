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

  Future<HistoryOrder?> getHistoryOrder(String workcode, int zoneId) async {
    final db = await _appDatabase.streamDatabase;
    final historyList = await db!.query(tableHistoryOrders,
        where: 'workcode != ? AND zone_id = ?', whereArgs: [workcode, zoneId]);
    final histories = parseHistories(historyList);
    if (histories.isNotEmpty) {
      return histories.first;
    } else {
      return null;
    }
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
