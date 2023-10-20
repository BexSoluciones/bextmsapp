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

  Future<WorkTypes> getWorkTypesFromWorkcode(String workcode) async {
    final db = await _appDatabase.streamDatabase;

    var deliveryList = await db!.query(t.tableTransactions,
        where: 'status = ? and workcode = ?',
        whereArgs: ['delivery', workcode]);
    var partialList = await db.query(t.tableTransactions,
        where: 'status = ? and workcode = ?', whereArgs: ['partial', workcode]);
    var respawnList = await db.query(t.tableTransactions,
        where: 'status = ? and workcode = ?', whereArgs: ['respawn', workcode]);
    var rejectList = await db.query(t.tableTransactions,
        where: 'status = ? and workcode = ?', whereArgs: ['reject', workcode]);

    var deliveries = parseTransactions(deliveryList);
    var partials = parseTransactions(partialList);
    var respawns = parseTransactions(respawnList);
    var rejects = parseTransactions(rejectList);

    return WorkTypes(
        delivery: deliveries.length,
        partial: partials.length,
        respawn: respawns.length,
        rejects: rejects.length);
  }

  Future<List<WorkAdditional>> getClientsResJetDel(String workcode, String reanson) async {
    final db = await _appDatabase.streamDatabase;
    final transactionList = await db!.rawQuery('''
    SELECT
      $tableTransactions.${TransactionFields.workcode},
      $tableTransactions.${TransactionFields.orderNumber},
      $tableTransactions.${TransactionFields.status},
      $tableWorks.*,
      $tableSummaries.*
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
      $tableTransactions.${TransactionFields.status} = '$reanson'
      AND $tableTransactions.${TransactionFields.workcode} = ?
  ''', [workcode]);

    final worksList = <WorkAdditional>[];
    for (var row in transactionList) {
      final work = Work(
        id: int.parse(row[WorkFields.id].toString()),
        workcode:row[WorkFields.workcode].toString(),
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
          createdAt: '',
          updatedAt: ''
      );

      var totalSummary = await getTotalSummariesWork( row[TransactionFields.orderNumber].toString());

      final workAdditional = WorkAdditional(
          work: work,
          orderNumber: row[TransactionFields.orderNumber].toString(),
          totalSummary: totalSummary,
          totalPayment: 0.0,
          status: row[SummaryFields.status].toString(),
          type: row[SummaryFields.type].toString(),
          latitude:double.parse(row[TransactionFields.latitude].toString()),
          longitude:double.parse(row[TransactionFields.longitude].toString()),
          summary:summary
      );
      worksList.add(workAdditional);

    }

    return worksList;
  }

  Future<double> countTotalCollectionWorks() async {
    final db = await _appDatabase.streamDatabase;

    var transactionList = await db!.query(t.tableTransactions,
        where: 'status = ? OR status = ?', whereArgs: ['delivery', 'partial']);
    var transactions = parseTransactions(transactionList);

    var sum = 0.0;
    for (var value in transactions) {
      if (value.payments != null) {
        for (var element in value.payments!) {
          try {
            sum += double.parse(element.paid.toString());
          } catch (e) {
            print('Error paid:$e');
          }
                }
      }
    }
    return sum;
  }



  Future<double> getTotalSummariesWork(String orderNumber) async {
    final db = await _appDatabase.streamDatabase;

    final summaryList = await db!.rawQuery('''
        SELECT $tableSummaries.* FROM $tableSummaries
        WHERE $tableSummaries.${SummaryFields.orderNumber} = "$orderNumber"
      ''');

    var sum = 0.0;
    summaryList.forEach((element) {
      var summary = Summary.fromJson(element);
      sum += summary.grandTotalCopy!;
    });
    return sum;
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

  Future<bool> checkLastTransaction(String workcode) async {
    final db = await _appDatabase.streamDatabase;

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

    if ((countSummaries - countTransactions) == 0) {
      return true;
    } else {
      return false;
    }
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