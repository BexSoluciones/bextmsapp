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
    final db = await _appDatabase.streamDatabase;

    final workList = await db!.rawQuery(
        '''
        SELECT works.*, 
        COUNT(DISTINCT number_customer || code_place) as count,
        COUNT(DISTINCT summaries.order_number) as left,
        COUNT(DISTINCT transactions.order_number) as right
        FROM $tableWorks 
        INNER JOIN $tableSummaries ON $tableSummaries.${SummaryFields.workId} = $tableWorks.${WorkFields.id}
        LEFT JOIN ${t.tableTransactions} ON (
          ${t.tableTransactions}.${t.TransactionFields.workId} = $tableWorks.${WorkFields.id} AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'start' AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'arrived' AND
          ${t.tableTransactions}.${t.TransactionFields.status} != 'summary'
        )
        GROUP BY $tableWorks.${WorkFields.workcode}
        '''
    );
    return parseWorks(workList);
  }

  Future<List<Work>> findAllWorksByWorkcode(String workcode) async {
    final db = await _appDatabase.streamDatabase;
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
    final works = parseWorks(workList);
    return works;
  }

  Future<int> countAllWorksByWorkcode(String workcode) async {
    final db = await _appDatabase.streamDatabase;
    final workList = await db!.rawQuery('''SELECT * FROM $tableWorks WHERE ${WorkFields.workcode} = "$workcode" ''');
    return workList.length;
  }

  Future<List<Work>> findAllWorksPaginatedByWorkcode(String workcode, int page) async {
    final db = await _appDatabase.streamDatabase;
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
        LIMIT $page, 10
        
     ''');
    //LIMIT $limit
    final works = parseWorks(workList);
    return works;
  }


  Future<int> insertWork(Work work) {
    return _appDatabase.insert(tableWorks, work.toJson());
  }

  Future<int> updateWork(Work work) {
    return _appDatabase.update(tableWorks, work.toJson(), 'id', work.id!);
  }

  Future<int> updateStatusWork(String workcode, String status) async {
    final db = await _appDatabase.streamDatabase;
    return db!.update(tableWorks, {'status': status },
        where: 'workcode = ?', whereArgs: [workcode]);
  }

  Future<void> insertWorks(List<Work> works) async {
    final db = await _appDatabase.streamDatabase;

    var batch = db!.batch();

    if (works.isNotEmpty) {
      await Future.forEach(works, (work) async {
        var d = await db.query(tableWorks, where: 'id = ?', whereArgs: [work.id]);
        var w = parseWorks(d);
        if (w.isEmpty) {
          batch.insert(tableWorks, work.toJson());
        } else {
          batch.update(tableWorks, work.toJson(), where: 'id = ?', whereArgs: [work.id]);
        }
      });
    }

    await batch.commit(noResult: true);

    return Future.value();
  }

  Future<int> insertPolylines(String workcode, List<LatLng> data) async {
    final db = await _appDatabase.streamDatabase;
    var batch = db!.batch();
    var existingData = await db.query('polylines', where: 'workcode = ?', whereArgs: [workcode]);
    var parsedData = parseWorks(existingData);

    if (parsedData.isEmpty) {
      List<Map<String, dynamic>> coordinatesList = [];
      if (data.isNotEmpty) {
        data.forEach((latLng) {
          coordinatesList.add(latLng.toJson());
        });
        String coordinatesString = jsonEncode(coordinatesList);
        batch.insert('polylines', {'workcode': workcode, 'polylines': coordinatesString});
      }
    }
    List<dynamic> results = await batch.commit();
    return results.length;
  }

  Future<List<LatLng>> getPolylines(String workcode) async {
    final db = await _appDatabase.streamDatabase;
    var existingData = await db!.query('polylines', where: 'workcode = ?', whereArgs: [workcode]);

    if (existingData.isNotEmpty) {
      String polylinesString = existingData[0]['polylines'].toString();
      List<dynamic> coordinatesList = jsonDecode(polylinesString);

      List<LatLng> polylines = [];
      coordinatesList.forEach((coordinate) {
        List<double> coordinates = List<double>.from(coordinate['coordinates']);
        LatLng latLng = LatLng(coordinates[1], coordinates[0]);
        polylines.add(latLng);
      });

      return polylines;
    } else {
      return [];
    }
  }



  Future<void> emptyWorks() async {
    final db = await _appDatabase.streamDatabase;
    await db!.delete(tableWorks, where: 'id > 0');
    return Future.value();
  }

}