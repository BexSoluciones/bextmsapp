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
    for (var summaryMap in summaryList) {
      final summary = SummaryReport.fromJson(summaryMap);
      summaries.add(summary);
    }
    return summaries;
  }

  Future<List<Summary>> getAllSummariesByOrderNumber(int workId) async {
    final db = await _appDatabase.database;
    var summaryList = await db!.rawQuery(''' 
            SELECT $tableSummaries.*, SUM($tableSummaries.${SummaryFields.grandTotalCopy}) as ${SummaryFields.grandTotalCopy},
            COUNT($tableSummaries.${SummaryFields.coditem}) AS count,
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
    _appDatabase.close();
    return parseSummaries(summaryList);
  }

  Future<List<Summary>> getAllSummariesByWorkcode(
      int workId, String customer) async {
    final db = await _appDatabase.database;
    final summaryList = await db!.query(tableSummaries,
        where: 'work_id = $workId', groupBy: SummaryFields.orderNumber);
    _appDatabase.close();
    return parseSummaries(summaryList);
  }

  Future<List<Summary>> getAllInventoryByOrderNumber(
      int workId, String orderNumber) async {
    final db = await _appDatabase.database;
    var summaryList = await db!.rawQuery('''
      SELECT $tableSummaries.*
      FROM $tableSummaries
      WHERE $tableSummaries.${SummaryFields.workId} = $workId 
      AND $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
    ''');
    _appDatabase.close();
    return parseSummaries(summaryList);
  }

  Future<List<Summary>> getAllInventoryByPackage(
      int workId, String orderNumber) async {
    final db = await _appDatabase.database;

    var summaryList = await db!.rawQuery('''
      SELECT $tableSummaries.*,
      SUM($tableSummaries.${SummaryFields.grandTotal}) as ${SummaryFields.grandTotal},
      COUNT($tableSummaries.${SummaryFields.coditem}) AS count
      FROM $tableSummaries
      WHERE $tableSummaries.${SummaryFields.workId} = $workId 
      AND $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
      GROUP BY $tableSummaries.${SummaryFields.idPacking}, $tableSummaries.${SummaryFields.packing}
    ''');
    _appDatabase.close();
    return parseSummaries(summaryList);
  }

  Future<List<Summary>> watchAllItemsPackage(
      String orderNumber, String packing, String idPacking) async {
    final db = await _appDatabase.database;

    var summaryList = await db!.rawQuery('''
      SELECT * FROM $tableSummaries 
      WHERE order_number="$orderNumber" 
      AND packing="$packing" 
      AND id_packing="$idPacking"
    ''');
    _appDatabase.close();
    return parseSummaries(summaryList);
  }

  Future<List<Summary>> getAllSummariesByOrderNumberMoved(
      int workId, String orderNumber) async {
    final db = await _appDatabase.database;
    var summaryList = await db!.rawQuery('''
            SELECT $tableSummaries.*
            FROM $tableSummaries
            WHERE $tableSummaries.${SummaryFields.workId} = $workId 
            AND $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
            AND $tableSummaries.${SummaryFields.minus} != 0
            ''');
    _appDatabase.close();
    return parseSummaries(summaryList);
  }

  Future<List<Summary>> getAllPackageByOrderNumber(
      int workId, String orderNumber) async {
    final db = await _appDatabase.database;
    var summaryList = await db!.rawQuery('''
            SELECT $tableSummaries.*,
            SUM($tableSummaries.${SummaryFields.grandTotal}) as ${SummaryFields.grandTotal},
            COUNT($tableSummaries.${SummaryFields.coditem}) AS count
            FROM $tableSummaries
            WHERE $tableSummaries.${SummaryFields.workId} = $workId 
            AND $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
            GROUP BY $tableSummaries.${SummaryFields.idPacking}, $tableSummaries.${SummaryFields.packing}
            ''');
    _appDatabase.close();
    return parseSummaries(summaryList);
  }

  Future<List<SummaryReport>> getSummaryReportsWithReasonOrRedelivery(
      String orderNumber) async {
    final db = await _appDatabase.database;
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
    _appDatabase.close();
    final parsedSummaries = parseSummariesReport(summaryList);
    return parsedSummaries;
  }

  Future<List<SummaryReport>> getSummaryReportsWithReturnOrRedelivery(
      String orderNumber) async {
    final db = await _appDatabase.database;
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
    _appDatabase.close();
    final parsedSummaries = parseSummariesReport(summaryList);
    return parsedSummaries;
  }

  Future<List<SummaryReport>> getSummaryReportsWithDelivery(
      String orderNumber) async {
    final db = await _appDatabase.database;
    final summaryList = await db!.rawQuery('''
      SELECT $tableSummaries.*, COALESCE(MAX($tableTransactions.${TransactionFields.reason}), 'ENTREGADO') AS reason
      FROM $tableSummaries
      LEFT JOIN $tableTransactions ON $tableTransactions.${TransactionFields.workId} = $tableSummaries.${SummaryReportFields.workId} AND $tableTransactions.${TransactionFields.orderNumber} = $tableSummaries.${SummaryReportFields.orderNumber} AND $tableTransactions.${TransactionFields.summaryId} = $tableSummaries.${SummaryFields.id}
      WHERE $tableSummaries.${SummaryReportFields.orderNumber} = ? 
      GROUP BY $tableSummaries.${SummaryFields.id}
      ORDER BY ${SummaryFields.id} ASC
    ''', [orderNumber]);
    _appDatabase.close();
    final parsedSummaries = parseSummariesReport(summaryList);
    return parsedSummaries;
  }

  Future<double> countTotalRespawnWorksByWorkcode(
      String workcode, String reason) async {
    final db = await _appDatabase.database;

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
    _appDatabase.close();
    return sum;
  }

  Future<bool> resetCantSummaries(int workId, String orderNumber) async {
    final db = await _appDatabase.database;

    final summaryList = await db!.rawQuery(''' 
       SELECT $tableSummaries.*
       FROM $tableSummaries INNER JOIN $tableWorks ON $tableWorks.${WorkFields.id} = $tableSummaries.${SummaryFields.workId}
       WHERE $tableWorks.${WorkFields.id} = $workId AND $tableSummaries.${SummaryFields.orderNumber} = $orderNumber
      ''');

    for (var element in summaryList) {
      var summary = Summary.fromJson(element);

      summary.cant = ((double.parse(summary.amount) *
                  100.0 /
                  double.parse(summary.unitOfMeasurement))
              .round() /
          100);
      summary.grandTotal = summary.grandTotalCopy!;
      summary.minus = 0;

      await updateSummary(summary);
    }
    _appDatabase.close();
    return true;
  }

  Future<double> getTotalSummaries(int workId, String orderNumber) async {
    final db = await _appDatabase.database;

    final summaryList = await db!.rawQuery('''
        SELECT $tableSummaries.*
        FROM $tableSummaries
        WHERE $tableSummaries.${SummaryFields.workId} = $workId 
        AND $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
     ''');

    var sum = 0.0;

    for (var element in summaryList) {
      var summary = Summary.fromJson(element);
      sum += summary.grandTotal;
    }
    _appDatabase.close();
    return double.parse(sum.toStringAsFixed(2));
  }

  Future<int> getTotalPackageSummaries(String orderNumber) async {
    final db = await _appDatabase.database;

    final summaryList = await db!.rawQuery('''
      SELECT COUNT(DISTINCT id_packing) AS total_columns
      FROM summaries
      WHERE order_number = ? 
    ''', [orderNumber]);

    final totalPackage = summaryList.isNotEmpty
        ? int.parse(summaryList[0]['total_columns'].toString())
        : 0;
    _appDatabase.close();
    return totalPackage;
  }

  Future<int> getTotalPackageSummariesLoose(String orderNumber) async {
    final db = await _appDatabase.database;

    final summaryList = await db!.rawQuery('''
      SELECT COUNT(order_number) AS loose
      FROM summaries
      WHERE order_number = ? AND (id_packing IS NULL OR id_packing = '') AND (packing IS NULL OR packing = '');
    ''', [orderNumber]);

    final totalLoose = summaryList.isNotEmpty
        ? int.parse(summaryList[0]['loose'].toString())
        : 0;
    _appDatabase.close();
    return totalLoose;
  }

  Future<int> insertSummary(Summary summary) {
    return _appDatabase.insert(tableSummaries, summary.toJson());
  }

  Future<int> updateSummary(Summary summary) {
    return _appDatabase.update(
        tableSummaries, summary.toJson(), 'id', summary.id);
  }

  Future<void> insertSummaries(List<Summary> summaries) async {
    final db = await _appDatabase.database;

    await db!.transaction((txn) async {
      var batch = txn.batch();

      if (summaries.isNotEmpty) {
        await Future.forEach(summaries, (summary) async {
          var d = await txn
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
    });

    return Future.value();
  }

  Future<int> deleteSummariesByWorkcode(String workcode) async {
    final db = await _appDatabase.database;
    return db!.rawDelete('''
      DELETE FROM summaries WHERE id IN (
        SELECT summaries.id FROM summaries INNER JOIN works ON works.id = summaries.work_id
        and works.workcode = ?
      )
     ''', [workcode]);
  }

  Future<void> emptySummaries() async {
    final db = await _appDatabase.database;
    await db!.delete(tableSummaries, where: 'id > 0');
    return Future.value();
  }
}
