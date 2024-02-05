part of '../app_database.dart';

class WorkDao {
  final AppDatabase _appDatabase;

  WorkDao(this._appDatabase);

  List<Work> parseWorks(List<Map<String, dynamic>> workList) {
    final works = <Work>[];
    for (var workMap in workList) {
      final work = Work.fromJson(workMap);
      works.add(work);
    }
    return works;
  }

  Future<List<Work>> getAllWorks() async {
    final db = await _appDatabase.database;

    final workList = await db!.rawQuery('''
        SELECT works.id, works.workcode, works.latitude, works.longitude,
        works.active, works.status, works.zone_id,
        COUNT(DISTINCT number_customer || code_place) as count,
        COUNT(DISTINCT summaries.order_number || works.number_customer || works.code_place) as left,
        COUNT(DISTINCT transactions.order_number || works.number_customer || works.code_place) as right
        FROM $tableWorks
        INNER JOIN $tableSummaries ON $tableSummaries.${SummaryFields.workId} = $tableWorks.${WorkFields.id}
        LEFT JOIN ${t.tableTransactions} ON (
          ${t.tableTransactions}.${t.TransactionFields.workId} = $tableWorks.${WorkFields.id} AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'start' AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'arrived' AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'summary'
        )  
        GROUP BY $tableWorks.${WorkFields.workcode}
    ''');
    _appDatabase.close();
    return parseWorks(workList);
  }

  Future<List<Work>> findAllWorksByWorkcode(String workcode) async {
    final db = await _appDatabase.database;
    final workList = await db!.rawQuery('''
        SELECT $tableWorks.*, 
        COUNT(DISTINCT $tableSummaries.${SummaryFields.orderNumber}) as count,
        CASE COUNT(DISTINCT summaries.order_number) = COUNT(DISTINCT transactions.order_number) WHEN 1 THEN 1 ELSE 0 END has_completed
        FROM $tableWorks
        INNER JOIN $tableSummaries ON $tableSummaries.${SummaryFields.workId} = $tableWorks.${WorkFields.id}
        LEFT JOIN ${t.tableTransactions} ON (
          ${t.tableTransactions}.${t.TransactionFields.workId} = $tableWorks.${WorkFields.id} AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'start' AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'arrived' AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'summary'
        )
        WHERE $tableWorks.${WorkFields.workcode} = "$workcode" AND $tableWorks.${WorkFields.status} != 'complete'
        GROUP BY $tableWorks.${WorkFields.numberCustomer}, $tableWorks.${WorkFields.codePlace}
        ORDER BY $tableWorks.${WorkFields.order} ASC
     ''');
    //LIMIT $limit
    _appDatabase.close();
    final works = parseWorks(workList);
    return works;
  }

  Future<int> countAllWorksByWorkcode(String workcode) async {
    final db = await _appDatabase.database;
    final workList = await db!.rawQuery(
        '''SELECT * FROM $tableWorks WHERE ${WorkFields.workcode} = "$workcode" ''');
    _appDatabase.close();
    return workList.length;
  }

  Future<List<Work>> findAllWorksPaginatedByWorkcode(
      String workcode, int page, int limit) async {
    final db = await _appDatabase.database;
    final workList = await db!.rawQuery('''
        SELECT $tableWorks.*, 
        COUNT(DISTINCT $tableSummaries.${SummaryFields.orderNumber}) as count,
        CASE COUNT(DISTINCT summaries.order_number) = COUNT(DISTINCT transactions.order_number) WHEN 1 THEN 1 ELSE 0 END has_completed
        FROM $tableWorks
        INNER JOIN $tableSummaries ON $tableSummaries.${SummaryFields.workId} = $tableWorks.${WorkFields.id}
        LEFT JOIN ${t.tableTransactions} ON (
          ${t.tableTransactions}.${t.TransactionFields.workId} = $tableWorks.${WorkFields.id} AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'start' AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'arrived' AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'summary'
        )
        WHERE $tableWorks.${WorkFields.workcode} = "$workcode" AND $tableWorks.${WorkFields.status} != 'complete'
        GROUP BY $tableWorks.${WorkFields.numberCustomer}, $tableWorks.${WorkFields.codePlace}
        ORDER BY $tableWorks.${WorkFields.order} ASC
        LIMIT $page, $limit
     ''');
    _appDatabase.close();
    final works = parseWorks(workList);
    return works;
  }

  Future<List<String>?> completeWorks() async {
    final db = await _appDatabase.database;

    final workList = await db!.rawQuery('''
        SELECT $tableWorks.${WorkFields.workcode} 
        FROM $tableWorks
        GROUP by $tableWorks.${WorkFields.workcode}
     ''');

    var works = parseWorks(workList);

    if (works.isNotEmpty) {
      var workcodes = <String>[];

      for (var work in works) {
        var resultSummaries = await db.rawQuery('''
         SELECT COUNT(DISTINCT summaries.order_number) as count
         FROM $tableSummaries
         INNER JOIN works ON works.id = summaries.work_id
         WHERE works.workcode = "${work.workcode}"
        ''');

        var resultTransactions = await db.rawQuery('''
         SELECT COUNT(DISTINCT transactions.order_number) as count
         FROM $tableTransactions
         INNER JOIN works ON transactions.work_id = works.id
         WHERE transactions.status != "start" AND
         transactions.status != "arrived" AND
         transactions.status != "summary" AND
         works.workcode = "${work.workcode}"
        ''');

        var countSummaries = resultSummaries[0]['count'];
        var countTransactions = resultTransactions[0]['count'];

        if (countSummaries == countTransactions) {
          workcodes.add(work.workcode!);
        }
      }

      _appDatabase.close();
      return workcodes;
    } else {
      return null;
    }
  }

  Future<int> insertWork(Work work) {
    return _appDatabase.insert(tableWorks, work.toJson());
  }

  Future<int> updateWork(Work work) {
    return _appDatabase.update(tableWorks, work.toJson(), 'id', work.id!);
  }

  Future<int> updateStatusWork(String workcode, String status) async {
    final db = await _appDatabase.database;
    return db!.update(tableWorks, {'status': status},
        where: 'workcode = ?', whereArgs: [workcode]);
  }

  Future<void> insertWorks(List<Work> works) async {
    final db = await _appDatabase.database;

    var batch = db!.batch();

    if (works.isNotEmpty) {
      await Future.forEach(works, (work) async {
        var d =
            await db.query(tableWorks, where: 'id = ?', whereArgs: [work.id]);
        var w = parseWorks(d);
        if (w.isEmpty) {
          batch.insert(tableWorks, work.toJson());
        } else {
          batch.update(tableWorks, work.toJson(),
              where: 'id = ?', whereArgs: [work.id]);
        }
      });
    }

    await batch.commit(noResult: true);

    return Future.value();
  }

  Future<int> insertPolylines(String workcode, List<LatLng> data) async {
    final db = await _appDatabase.database;
    var batch = db!.batch();
    var existingData = await db
        .query('polylines', where: 'workcode = ?', whereArgs: [workcode]);
    var parsedData = parseWorks(existingData);

    if (parsedData.isEmpty) {
      List<Map<String, dynamic>> coordinatesList = [];
      if (data.isNotEmpty) {
        for (var latLng in data) {
          coordinatesList.add(latLng.toJson());
        }
        String coordinatesString = jsonEncode(coordinatesList);
        batch.insert('polylines',
            {'workcode': workcode, 'polylines': coordinatesString});
      }
    }
    List<dynamic> results = await batch.commit();
    return results.length;
  }

  Future<List<LatLng>> getPolylines(String workcode) async {
    final db = await _appDatabase.database;
    var existingData = await db!
        .query('polylines', where: 'workcode = ?', whereArgs: [workcode]);

    if (existingData.isNotEmpty) {
      String polylinesString = existingData[0]['polylines'].toString();
      List<dynamic> coordinatesList = jsonDecode(polylinesString);

      List<LatLng> polylines = [];
      for (var coordinate in coordinatesList) {
        List<double> coordinates = List<double>.from(coordinate['coordinates']);
        LatLng latLng = LatLng(coordinates[1], coordinates[0]);
        polylines.add(latLng);
      }
      return polylines;
    } else {
      return [];
    }
  }

  Future<int> deleteWorksByWorkcode(String workcode) async {
    final db = await _appDatabase.database;
    return db!.delete(tableWorks, where: 'workcode = ?', whereArgs: [workcode]);
  }

  Future<void> emptyWorks() async {
    final db = await _appDatabase.database;
    await db!.delete(tableWorks, where: 'id > 0');
    return Future.value();
  }
}
