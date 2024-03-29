part of '../app_database.dart';

class TransactionDao {
  final AppDatabase _appDatabase;

  TransactionDao(this._appDatabase);

  List<t.Transaction> parseTransactions(
      List<Map<String, dynamic>> transactionList) {
    final transactions = <t.Transaction>[];
    for (var transactionMap in transactionList) {
      final transaction = t.Transaction.fromJson(transactionMap);
      transactions.add(transaction);
    }
    return transactions;
  }

  List<TransactionValidate> parseValidateTransactions(
      List<Map<String, dynamic>> transactionList) {
    final transactions = <TransactionValidate>[];
    for (var transactionMap in transactionList) {
      final transaction = TransactionValidate.fromJson(transactionMap);
      transactions.add(transaction);
    }
    return transactions;
  }

  Future<WorkTypes> getWorkTypesFromWorkcode(String workcode) async {
    final db = await _appDatabase.database;

    var deliveryList = await db!.query(t.tableTransactions,
        columns: ['work_id', 'status'],
        where: 'status = ? and workcode = ?',
        whereArgs: ['delivery', workcode]);
    var partialList = await db.query(t.tableTransactions,
        columns: ['work_id', 'status'],
        where: 'status = ? and workcode = ?',
        whereArgs: ['partial', workcode]);
    var respawnList = await db.query(t.tableTransactions,
        columns: ['work_id', 'status'],
        where: 'status = ? and workcode = ?',
        whereArgs: ['respawn', workcode]);
    var rejectList = await db.query(t.tableTransactions,
        columns: ['work_id', 'status'],
        where: 'status = ? and workcode = ?',
        whereArgs: ['reject', workcode]);

    var deliveries = parseTransactions(deliveryList);
    var partials = parseTransactions(partialList);
    var respawns = parseTransactions(respawnList);
    var rejects = parseTransactions(rejectList);

    _appDatabase.close();
    return WorkTypes(
        delivery: deliveries.length,
        partial: partials.length,
        respawn: respawns.length,
        rejects: rejects.length);
  }

  Future<List<WorkAdditional>> getClientsResJetDel(
      String workcode, String reason) async {
    final db = await _appDatabase.database;

    final transactionList = await db!.rawQuery('''
    SELECT
      $tableTransactions.${TransactionFields.workcode},
      $tableTransactions.${TransactionFields.orderNumber},
      $tableTransactions.${TransactionFields.status},
      $tableTransactions.${TransactionFields.payments},
      $tableWorks.${WorkFields.id},
      $tableWorks.${WorkFields.workcode},
      $tableWorks.${WorkFields.nameTransporter},
      $tableWorks.${WorkFields.date},
      $tableWorks.${WorkFields.latitude},
      $tableWorks.${WorkFields.longitude},
      $tableWorks.${WorkFields.numberCustomer},
      $tableWorks.${WorkFields.type},
      $tableWorks.${WorkFields.customer},
      $tableWorks.${WorkFields.address},
      $tableSummaries.${SummaryFields.id},
      $tableSummaries.${SummaryFields.workId},
      $tableSummaries.${SummaryFields.orderNumber},
      $tableSummaries.${SummaryFields.coditem},
      $tableSummaries.${SummaryFields.nameItem},
      $tableSummaries.${SummaryFields.amount},
      $tableSummaries.${SummaryFields.codeWarehouse},
      $tableSummaries.${SummaryFields.cant},
      $tableSummaries.${SummaryFields.unitOfMeasurement},
      $tableSummaries.${SummaryFields.grandTotalCopy},
      $tableSummaries.${SummaryFields.price},
      $tableSummaries.${SummaryFields.typeItem},
      $tableSummaries.${SummaryFields.typeTransaction}
    FROM
      $tableTransactions
    INNER JOIN
      $tableWorks,
      $tableSummaries
    ON
      $tableTransactions.${TransactionFields.workcode} = $tableWorks.${WorkFields.workcode} AND 
      $tableTransactions.${TransactionFields.workId} = $tableWorks.${WorkFields.id} AND 
      $tableSummaries.${SummaryFields.id} = $tableTransactions.${TransactionFields.summaryId} 
    WHERE
      $tableTransactions.${TransactionFields.status} = ?
      AND $tableTransactions.${TransactionFields.workcode} = ?
  ''', [reason, workcode]);

    final worksList = <WorkAdditional>[];
    for (var row in transactionList) {
      final work = Work(
        id: int.parse(row[WorkFields.id].toString()),
        workcode: row[WorkFields.workcode].toString(),
        nameTransporter: row[WorkFields.nameTransporter].toString(),
        date: row[WorkFields.date].toString(),
        latitude: row[WorkFields.latitude].toString(),
        longitude: row[WorkFields.longitude].toString(),
        numberCustomer: row[WorkFields.numberCustomer].toString(),
        type: row[WorkFields.type].toString(),
        customer: row[WorkFields.customer].toString(),
        address: row[WorkFields.address].toString(),
      );

      final summary = Summary(
        id: int.parse(row[SummaryFields.id].toString()),
        workId: int.parse(row[SummaryFields.workId].toString()),
        orderNumber: row[SummaryFields.orderNumber].toString(),
        coditem: row[SummaryFields.coditem].toString(),
        nameItem: row[SummaryFields.nameItem].toString(),
        amount: row[SummaryFields.amount].toString(),
        codeWarehouse: row[SummaryFields.codeWarehouse].toString(),
        cant: double.parse(row[SummaryFields.cant].toString()),
        unitOfMeasurement: row[SummaryFields.unitOfMeasurement].toString(),
        grandTotal: double.parse(row[SummaryFields.grandTotalCopy].toString()),
        price: double.parse(row[SummaryFields.price].toString()),
        typeItem: row[SummaryFields.typeItem].toString(),
        typeTransaction: row[SummaryFields.typeTransaction].toString(),
        minus: 0,
      );

      var totalSummary = await getTotalSummariesWork(
          row[TransactionFields.orderNumber].toString());

      var totalPayment = 0.0;

      if (row[t.TransactionFields.payments] != null) {
        var payments = List<Payment>.from(
            jsonDecode(row[t.TransactionFields.payments] as String)
                .map((e) => Payment.fromJson(e)));

        totalPayment += payments.fold<double>(
            0, (sum, item) => sum + double.parse(item.paid));
      }

      final workAdditional = WorkAdditional(
          work: work,
          orderNumber: row[TransactionFields.orderNumber].toString(),
          totalSummary: totalSummary,
          totalPayment: totalPayment,
          status: row[t.TransactionFields.status].toString(),
          type: row[SummaryFields.type].toString(),
          latitude: double.parse(row[TransactionFields.latitude].toString()),
          longitude: double.parse(row[TransactionFields.longitude].toString()),
          summary: summary);
      worksList.add(workAdditional);
    }

    _appDatabase.close();
    return worksList;
  }

  Future<double> countTotalCollectionWorks() async {
    final db = await _appDatabase.database;

    var transactionList = await db!.query(t.tableTransactions,
        columns: ['work_id', 'status', 'payments'],
        where: 'status = ? OR status = ?',
        whereArgs: ['delivery', 'partial']);

    var transactions = parseTransactions(transactionList);

    var sum = 0.0;
    for (var value in transactions) {
      if (value.payments != null) {
        for (var element in value.payments!) {
          sum += double.tryParse(element.paid.toString()) ?? 0;
        }
      }
    }

    _appDatabase.close();
    return sum;
  }

  Future<double> getTotalSummariesWork(String orderNumber) async {
    final db = await _appDatabase.database;

    final summaryList = await db!.rawQuery('''
        SELECT $tableSummaries.* FROM $tableSummaries
        WHERE $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
      ''');

    var sum = 0.0;
    for (var element in summaryList) {
      var summary = Summary.fromJson(element);
      sum += summary.grandTotalCopy!;
    }

    _appDatabase.close();
    return sum;
  }

  Future<double> countTotalCollectionWorksByWorkcode(String workcode) async {
    final db = await _appDatabase.database;

    var transactionList = await db!.query(t.tableTransactions,
        columns: ['work_id', 'status', 'payments'],
        where:
            'status != ? AND status != ? AND status != ? AND status != ? AND status != ? AND workcode = ?',
        whereArgs: [
          'reject',
          'respawn',
          'start',
          'arrived',
          'summary',
          workcode
        ]);

    var transactions = parseTransactions(transactionList);

    var sum = 0.0;

    for (var value in transactions) {
      sum += value.payments!
          .fold(0, (value, element) => value + double.parse(element.paid));
    }

    _appDatabase.close();
    return sum;
  }

  Future<int> countLeftClients(String workcode) async {
    final db = await _appDatabase.database;

    var validateList = await db?.rawQuery('''
          SELECT $tableWorks.${WorkFields.id} as work_id, 
          (SELECT count(DISTINCT $tableSummaries.${SummaryFields.orderNumber}) FROM $tableSummaries WHERE $tableSummaries.${SummaryFields.workId} = $tableWorks.${WorkFields.id}) as countSummaries,
          COUNT(DISTINCT $tableTransactions.${TransactionFields.orderNumber}) as countTransactions 
          FROM $tableWorks
          LEFT JOIN $tableTransactions ON ($tableTransactions.${TransactionFields.workId} = $tableWorks.${WorkFields.id}
          AND $tableTransactions.${TransactionFields.status} != 'start' AND $tableTransactions.${TransactionFields.status} != 'arrived' AND $tableTransactions.${TransactionFields.status} != 'summary')
          WHERE $tableWorks.${WorkFields.workcode} = "$workcode" 
          GROUP BY $tableWorks.${WorkFields.numberCustomer}, $tableWorks.${WorkFields.codePlace}
          ORDER BY ${WorkFields.order} ASC
        ''');

    var vl = parseValidateTransactions(validateList!);

    var clients = 0;

    await Future.forEach(vl, (v) async {
      if (v.countSummaries == v.countTransactions) {
        clients += 1;
      }
    });

    _appDatabase.close();
    return clients.toInt();
  }

  Future<bool> verifyTransactionExistence(
      int workId, String orderNumber) async {
    final db = await _appDatabase.database;
    List<Map<String, dynamic>> result = await db!.rawQuery(
      'SELECT COUNT(*) FROM transactions WHERE work_Id = ? AND order_number = ? AND status != ?',
      [workId, orderNumber, 'summary'],
    );

    int count = Sqflite.firstIntValue(result)!;

    _appDatabase.close();
    return count > 1;
  }

  Future<List<t.Transaction>> getAllTransactions() async {
    final db = await _appDatabase.database;
    final transactionList = await db!.rawQuery('''
        SELECT * FROM ${t.tableTransactions} 
        WHERE status != "start" and status != "arrived" and status != "summary" 
    ''');

    _appDatabase.close();
    return parseTransactions(transactionList);
  }

  Future<String?> getDiffTime(int workId) async {
    final db = await _appDatabase.database;

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
    _appDatabase.close();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<bool> validateTransaction(int workId) async {
    final db = await _appDatabase.database;

    final transactionList = await db!.query(t.tableTransactions,
        columns: ['id'],
        where: 'work_id = ? AND status != ? AND status != ? AND status != ?',
        whereArgs: [workId, 'arrived', 'start', 'summary']);

    final summaryList = await db.query(tableSummaries,
        columns: ['id', 'order_number'],
        where: 'work_id = ?',
        whereArgs: [workId],
        groupBy: '$tableSummaries.${SummaryFields.orderNumber}');

    _appDatabase.close();
    return transactionList.isNotEmpty &&
        summaryList.isNotEmpty &&
        (transactionList.length == summaryList.length);
  }

  Future<bool> validateSubTransaction(int workId, String orderNumber) async {
    final db = await _appDatabase.database;

    final transactionList = await db!.query(t.tableTransactions,
        where: 'work_id = ? AND order_number = ? AND status != ?',
        whereArgs: [workId, orderNumber, 'summary']);

    _appDatabase.close();
    return transactionList.isNotEmpty;
  }

  Future<bool> validateTransactionSummary(
      String workcode, String orderNumber, String status) async {
    final db = await _appDatabase.database;
    final transactionList = await db!.query(t.tableTransactions,
        where: 'workcode = ? AND order_number = ? AND status = ?',
        whereArgs: [workcode, orderNumber, status]);

    _appDatabase.close();
    final transactions = parseTransactions(transactionList);
    return transactions.isNotEmpty;
  }

  Future<bool> validateTransactionStart(String workcode, String status) async {
    final db = await _appDatabase.database;

    var transactionList = await db!.query(t.tableTransactions,
        columns: ['id'],
        where: 'workcode = ? AND status = ?',
        whereArgs: [workcode, status]);

    _appDatabase.close();
    return transactionList.isNotEmpty;
  }

  Future<bool> validateTransactionArrived(int workId, String status) async {
    final db = await _appDatabase.database;

    final transactionList = await db!.query(t.tableTransactions,
        columns: ['id'],
        where: 'work_id = ? AND status = ?',
        whereArgs: [workId, status]);

    _appDatabase.close();
    return transactionList.isNotEmpty;
  }

  Future<bool> checkLastTransaction(String workcode) async {
    final db = await _appDatabase.database;

    var summaries = await db!.rawQuery('''
      select COUNT(distinct order_number) as count from summaries inner join works on works.id = summaries.work_id
      where works.workcode = "$workcode"
    ''');

    var transactions = await db.rawQuery('''
      select COUNT(id) as count from transactions 
      where status != 'start' and status != 'arrived' and status != 'summary' and workcode = "$workcode"
    ''');

    var countSummaries = summaries[0]['count'] as int;
    var countTransactions = transactions[0]['count'] as int;

    _appDatabase.close();

    if ((countSummaries - countTransactions) == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkLastProduct(int transactionId) async {
    final db = await _appDatabase.database;

    var validateIsLastProduct = await db!.rawQuery('''
      select id from processing_queues
      where relation_id = $transactionId
      order by id desc
    ''');

    _appDatabase.close();

    if (validateIsLastProduct.last['status'] == 'processing') {
      return true;
    } else {
      return false;
    }
  }

  Stream<bool?> watchTransactionClient(String workcode, String status) async* {
    final db = await _appDatabase.database;

    final transactionList = await db!.query(t.tableTransactions,
        columns: ['id'],
        where: 'workcode = ? AND status = ?',
        whereArgs: [workcode, status]);

    yield transactionList.isNotEmpty;
  }

  Future<int> insertTransaction(t.Transaction transaction) {
    return _appDatabase.insert(t.tableTransactions, transaction.toJson());
  }

  Future<int> insertTransactionSummary(TransactionSummary transactionSummary) {
    return _appDatabase.insert(
        tableTransactionSummaries, transactionSummary.toJson());
  }

  Future<int> updateTransaction(t.Transaction transaction) {
    return _appDatabase.update(
        t.tableTransactions, transaction.toJson(), 'id', transaction.id!);
  }

  Future<void> insertTransactions(List<t.Transaction> transactions) async {
    final db = await _appDatabase.database;

    await db!.transaction((txn) async {
      var batch = txn.batch();
      if (transactions.isNotEmpty) {
        await Future.forEach(transactions, (transaction) async {
          var d = await txn.query(t.tableTransactions,
              where: 'id = ?', whereArgs: [transaction.id]);
          var w = parseTransactions(d);
          if (w.isEmpty) {
            batch.insert(t.tableTransactions, transaction.toJson());
          } else {
            batch.update(t.tableTransactions, transaction.toJson(),
                where: 'id = ?', whereArgs: [transaction.id]);
          }
        });
      }

      await batch.commit(noResult: false, continueOnError: true);
    });

    return Future.value();
  }

  Future<void> emptyTransactions() async {
    final db = await _appDatabase.database;
    await db!.delete(t.tableTransactions, where: 'id > 0');
    return Future.value();
  }

  Future<int> deleteTransactionByDays() async {
    final db = await _appDatabase.database;
    var today = DateTime.now();
    var limitDaysWork = _storageService.getInt('limit_days_works') ?? 3;
    var datesToValidate = today.subtract(Duration(days: limitDaysWork));
    List<Map<String, dynamic>> transactionToDelete;

    var formattedToday = DateTime(today.year, today.month, today.day);
    var formattedDatesToValidate = DateTime(
        datesToValidate.year, datesToValidate.month, datesToValidate.day);
    var formattedDatesToValidateStr =
        formattedDatesToValidate.toIso8601String().split('T')[0];

    transactionToDelete = await db!.query(
      tableTransactions,
      where: 'substr(end, 1, 10) <= ?',
      whereArgs: [formattedDatesToValidateStr],
    );

    for (var task in transactionToDelete) {
      var createdAt = DateTime.parse(task['end']);
      var differenceInDays = formattedToday.difference(createdAt).inDays;
      if (differenceInDays > limitDaysWork) {
        await db.delete(
          tableTransactions,
          where: 'id = ?',
          whereArgs: [task['id']],
        );
      }
    }

    return db.delete(
      tableTransactions,
      where: 'substr(end, 1, 10) <= ?',
      whereArgs: [formattedDatesToValidateStr],
    );
  }

  Future<int> deleteTransactionsByWorkcode(String workcode) async {
    final db = await _appDatabase.database;
    return db!.delete(tableTransactions,
        where: 'workcode = ?', whereArgs: [workcode]);
  }
}
