part of '../app_database.dart';

class ReasonDao {
  final AppDatabase _appDatabase;

  ReasonDao(this._appDatabase);

  List<Reason> parseReasons(List<Map<String, dynamic>> reasonList) {
    final reasons = <Reason>[];
    for (var reasonMap in reasonList) {
      final reason = Reason.fromJson(reasonMap);
      reasons.add(reason);
    }
    return reasons;
  }

  Future<List<Reason>> getAllReasons() async {
    final db = await _appDatabase.streamDatabase;
    final reasonList = await db!.query(tableReasons);
    final reasons = parseReasons(reasonList);
    return reasons;
  }

  Future<Reason?> findReason(String name) async {
    final db = await _appDatabase.streamDatabase;
    final reasonList =
    await db!.query(tableReasons, where: 'nommotvis = ?', whereArgs: [name]);
    final reason = parseReasons(reasonList);
    if(reason.isEmpty){
      return null;
    }
    return reason.first;
  }

  Future<int> insertReason(Reason reason) {
    return _appDatabase.insert(tableReasons, reason.toJson());
  }

  Future<int> updateReason(Reason reason) {
    return _appDatabase.update(tableReasons, reason.toJson(), 'id', reason.id);
  }

  Future<void> insertReasons(List<Reason> reasons) async {
    final db = await _appDatabase.streamDatabase;
    var batch = db!.batch();

    if (reasons.isNotEmpty) {
      await Future.forEach(reasons, (reason) async {
        var d = await db.query(tableReasons, where: 'id = ?', whereArgs: [reason.id]);
        var w = parseReasons(d);
        if (w.isEmpty) {
          batch.insert(tableReasons, reason.toJson());
        } else {
          batch.update(tableReasons, reason.toJson(), where: 'id = ?', whereArgs: [reason.id]);
        }
      });
    }
    await batch.commit(noResult: true);
    return Future.value();
  }

  Future<int> insertNews(News news) async {
    return _appDatabase.insert(tableNews, news.toJson());
  }

  Future<void> emptyReasons() async {
    final db = await _appDatabase.streamDatabase;
    await db!.delete(tableReasons, where: 'id > 0');
    return Future.value();
  }
}
