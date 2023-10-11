part of '../app_database.dart';

class SummaryDao {
  final AppDatabase _appDatabase;

  SummaryDao(this._appDatabase);

  List<Summary> parseSummaries(List<Map<String, dynamic>> summaryList) {
    final summaries = <Summary>[];
    for (var summaryMap in summaryList) {
      final summary = Summary.fromJson(summaryMap);
      summaries.add(summary);
    }
    return summaries;
  }

  List<SummaryReport> parseSummariesReport(
      List<Map<String, dynamic>> summaryList) {
    final summaries = <SummaryReport>[];
    summaryList.forEach((summaryMap) {
      final summary = SummaryReport.fromJson(summaryMap);
      summaries.add(summary);
    });
    return summaries;
  }

  Future<List<Summary>> getAllSummariesByOrderNumber(int workId) async {
    final db = await _appDatabase.streamDatabase;
    var summaryList = await db!.rawQuery(''' 
            SELECT $tableSummaries.*, SUM(DISTINCT $tableSummaries.${SummaryFields.grandTotalCopy}) as ${SummaryFields.grandTotalCopy},
            COUNT(DISTINCT $tableSummaries.${SummaryFields.coditem}) AS count,
            CASE id_packing IS NOT NULL WHEN 1 THEN 1 ELSE 0 END validate,
            CASE transactions.id IS NOT NULL WHEN 1 THEN 1 ELSE 0 END has_transaction
            FROM $tableSummaries 
            LEFT JOIN ${t.tableTransactions} ON (
              ${t.tableTransactions}.${t.TransactionFields.summaryId} = $tableSummaries.${SummaryFields.id} AND
              ${t.tableTransactions}.${t.TransactionFields.status} != 'arrived' AND
              ${t.tableTransactions}.${t.TransactionFields.status} != 'summary'
            )
            WHERE $tableSummaries.${SummaryFields.workId} = $workId
            GROUP BY $tableSummaries.${SummaryFields.orderNumber}
            ORDER BY $tableSummaries.${SummaryFields.id} DESC
          ''');
    return parseSummaries(summaryList);
  }

  Future<List<Summary>> getAllInventoryByOrderNumber(int workId, String orderNumber) async {
    final db = await _appDatabase.streamDatabase;
    var summaryList = await db!.rawQuery('''
            SELECT $tableSummaries.*
            FROM $tableSummaries
            WHERE $tableSummaries.${SummaryFields.workId} = $workId 
            AND $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
            ''');
    return parseSummaries(summaryList);
  }

  Future<List<Summary>> getAllSummariesByOrderNumberMoved(int workId, String orderNumber) async {
    final db = await _appDatabase.streamDatabase;
    var summaryList = await db!.rawQuery('''
            SELECT $tableSummaries.*
            FROM $tableSummaries
            WHERE $tableSummaries.${SummaryFields.workId} = $workId 
            AND $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
            AND $tableSummaries.${SummaryFields.minus} != 0
            ''');
    return parseSummaries(summaryList);
  }

  Future<List<Summary>> getAllPackageByOrderNumber(int workId, String orderNumber) async {
    final db = await _appDatabase.streamDatabase;
    var summaryList = await db!.rawQuery('''
            SELECT $tableSummaries.*,
            SUM($tableSummaries.${SummaryFields.grandTotal}) as ${SummaryFields.grandTotal},
            COUNT($tableSummaries.${SummaryFields.coditem}) AS count
            FROM $tableSummaries
            WHERE $tableSummaries.${SummaryFields.workId} = $workId 
            AND $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
            GROUP BY $tableSummaries.${SummaryFields.idPacking}, $tableSummaries.${SummaryFields.packing}
            ''');
    return parseSummaries(summaryList);
  }

  Future<List<SummaryReport>> getSummaryReportsWithReasonOrRedelivery(
      String orderNumber) async {
    final db = await _appDatabase.streamDatabase;
    final summaryList = await db!.rawQuery('''
    SELECT  $tableSummaries.* ,
    CASE WHEN transactions.reason = '' OR transactions.reason IS NULL
    THEN 'REDESPACHO'
    ELSE transactions.reason
    END AS reason
    FROM summaries
    INNER JOIN transactions ON (transactions.order_number = summaries.order_number AND transactions.work_id = summaries.work_id AND transactions.`status` = 'respawn')
    WHERE summaries.order_number = $orderNumber
    GROUP BY summaries.name_item
   ORDER BY summaries.id ASC;
  ''');

    final parsedSummaries = parseSummariesReport(summaryList);
    return parsedSummaries;
  }

  Future<List<SummaryReport>> getSummaryReportsWithReturnOrRedelivery(String orderNumber) async {
    final db = await _appDatabase.streamDatabase;
    final summaryList = await db!.rawQuery('''
    SELECT  $tableSummaries.* ,
    CASE WHEN transactions.reason = '' OR transactions.reason IS NULL
    THEN 'RECHAZADO'
    ELSE transactions.reason
    END AS reason
    FROM summaries
    INNER JOIN transactions ON (transactions.order_number = summaries.order_number AND transactions.work_id = summaries.work_id AND transactions.`status` = 'reject')
    WHERE summaries.order_number = $orderNumber
    GROUP BY summaries.name_item
   ORDER BY summaries.id ASC;
  ''');

    final parsedSummaries = parseSummariesReport(summaryList);
    return parsedSummaries;
  }

  Future<List<SummaryReport>> getSummaryReportsWithDelivery(String orderNumber) async {
    final db = await _appDatabase.streamDatabase;
    final summaryList = await db!.rawQuery('''
    SELECT $tableSummaries.*, COALESCE(MAX($tableTransactions.${TransactionFields.reason}), 'ENTREGADO') AS reason
    FROM $tableSummaries
    LEFT JOIN $tableTransactions ON $tableTransactions.${TransactionFields.workId} = $tableSummaries.${SummaryReportFields.workId} AND $tableTransactions.${TransactionFields.orderNumber} = $tableSummaries.${SummaryReportFields.orderNumber} AND $tableTransactions.${TransactionFields.summaryId} = $tableSummaries.${SummaryFields.id}
    WHERE $tableSummaries.${SummaryReportFields.orderNumber} = ? 
    GROUP BY $tableSummaries.${SummaryFields.id}
    ORDER BY ${SummaryFields.id} ASC
  ''', [orderNumber]);

    final parsedSummaries = parseSummariesReport(summaryList);
    return parsedSummaries;
  }


  Future<double> countTotalRespawnWorksByWorkcode(String workcode,String reason) async {
    final db = await _appDatabase.streamDatabase;

    var summaryList = await db!.rawQuery('''
    SELECT $tableSummaries.*, SUM($tableSummaries.${SummaryFields.grandTotal}) as ${SummaryFields.grandTotal}, COUNT($tableSummaries.${SummaryFields.coditem}) AS count 
    FROM $tableSummaries 
    INNER JOIN $tableWorks ON $tableWorks.${WorkFields.id} = $tableSummaries.${SummaryFields.workId}
    INNER JOIN ${t.tableTransactions} ON ${t.tableTransactions}.${t.TransactionFields.workId} = $tableWorks.${WorkFields.id}
    WHERE ${t.tableTransactions}.${t.TransactionFields.status} = '$reason'
    AND $tableWorks.${WorkFields.workcode} = "$workcode"
    GROUP BY $tableSummaries.${SummaryFields.orderNumber}
  ''');

    var summaries = parseSummaries(summaryList);
    var sum = 0.0;

    for (var value in summaries) {
      sum += value.grandTotal;
    }
    return sum;
  }

  Future<bool> resetCantSummaries(int workId, String orderNumber) async {
    final db = await _appDatabase.streamDatabase;

    final summaryList = await db!.rawQuery(''' 
       SELECT $tableSummaries.*
       FROM $tableSummaries INNER JOIN $tableWorks ON $tableWorks.${WorkFields.id} = $tableSummaries.${SummaryFields.workId}
       WHERE $tableWorks.${WorkFields.id} = $workId AND $tableSummaries.${SummaryFields.orderNumber} = $orderNumber
      ''');

    for (var element in summaryList) {
      var summary = Summary.fromJson(element);

      summary.cant = ((double.parse(summary.amount) * 100.0 / double.parse(summary.unitOfMeasurement)).round() / 100);
      summary.grandTotal = summary.grandTotalCopy!;
      summary.minus = 0;

      await updateSummary(summary);
    }

    return true;
  }

  Future<double> getTotalSummaries(int workId, String orderNumber) async {
    final db = await _appDatabase.streamDatabase;

    final summaryList = await db!.rawQuery('''
        SELECT $tableSummaries.*
        FROM $tableSummaries
        WHERE $tableSummaries.${SummaryFields.workId} = $workId AND $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
      ''');

    var sum = 0.0;

    for (var element in summaryList) {
      var summary = Summary.fromJson(element);
      sum += summary.grandTotal;
    }

    return sum;
  }

  Future<int> insertSummary(Summary summary) {
    return _appDatabase.insert(tableSummaries, summary.toJson());
  }

  Future<int> updateSummary(Summary summary) {
    return _appDatabase.update(
        tableSummaries, summary.toJson(), 'id', summary.id);
  }

  Future<void> insertSummaries(List<Summary> summaries) async {
    final db = await _appDatabase.streamDatabase;

    var batch = db!.batch();

    if (summaries.isNotEmpty) {
      await Future.forEach(summaries, (summary) async {
        var d = await db
            .query(tableSummaries, where: 'id = ?', whereArgs: [summary.id]);
        var w = parseSummaries(d);
        if (w.isEmpty) {
          batch.insert(tableSummaries, summary.toJson());
        } else {
          batch.update(tableSummaries, summary.toJson(),
              where: 'id = ?', whereArgs: [summary.id]);
        }
      });
    }

    await batch.commit(noResult: true);

    return Future.value();
  }

  Future<void> emptySummaries() async {
    final db = await _appDatabase.streamDatabase;
    await db!.delete(tableSummaries, where: 'id > 0');
    return Future.value();
  }
}
