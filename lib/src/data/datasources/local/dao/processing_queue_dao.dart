part of '../app_database.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class ProcessingQueueDao {
  final AppDatabase _appDatabase;

  ProcessingQueueDao(this._appDatabase);

  List<ProcessingQueue> parseProcessingQueues(
      List<Map<String, dynamic>> processingQueueList) {
    final processingQueues = <ProcessingQueue>[];
    for (var processingQueueMap in processingQueueList) {
      final processingQueue = ProcessingQueue.fromJson(processingQueueMap);
      processingQueues.add(processingQueue);
    }
    return processingQueues;
  }

  Future<List<ProcessingQueue>> getAllProcessingQueues(
      String? code, String? task) async {
    final db = await _appDatabase.streamDatabase;
    var processingQueueList = <Map<String, dynamic>>[];
    if (code != null) {
      processingQueueList = await db!
          .query(tableProcessingQueues, where: 'code = ?', whereArgs: [code]);
    } else if (task != null) {
      processingQueueList = await db!
          .query(tableProcessingQueues, where: 'task = ?', whereArgs: [task]);
    } else if (code != null && task != null) {
      processingQueueList = await db!.query(tableProcessingQueues,
          where: 'task = ? and code = ?', whereArgs: [task, code]);
    } else {
      processingQueueList = await db!.query(tableProcessingQueues);
    }

    final processingQueues = parseProcessingQueues(processingQueueList);
    return processingQueues;
  }

  Future<List<ProcessingQueue>> getAllProcessingQueuesPaginated(
    int? page,
    int? limit,
  ) async {
    final db = await _appDatabase.streamDatabase;
    var processingQueueList = await db!.rawQuery('''
      SELECT id, code, task, created_at, updated_at, _error FROM $tableProcessingQueues
      ORDER BY $tableProcessingQueues.${ProcessingQueueFields.createdAt} DESC
      LIMIT $limit
      OFFSET $page
    ''');

    final processingQueues = parseProcessingQueues(processingQueueList);
    return processingQueues;
  }

  Future<ProcessingQueue> findProcessingQueue(int id) async {
    final db = await _appDatabase.streamDatabase;
    final processingQueueList = await db!
        .query(tableProcessingQueues,
        columns: ['task', 'code', 'body'],
        where: 'id = ?', whereArgs: [id]);
    final processingQueues = parseProcessingQueues(processingQueueList);
    return processingQueues.first;
  }

  Stream<List<ProcessingQueue>> watchAllProcessingQueues() async* {
    final db = await _appDatabase.streamDatabase;
    final processingQueueList = await db!.query(tableProcessingQueues);
    final processingQueues = parseProcessingQueues(processingQueueList);
    yield processingQueues;
  }

  Stream<List<Map<String, dynamic>>>
      getProcessingQueueIncompleteToTransactions() async* {
    final db = await _appDatabase.streamDatabase;
    final handleNames = {
      'store_transaction_start': 'Transacciones de inicio de servicio',
      'store_transaction_arrived': 'Transacciones de llegada de cliente',
      'store_transaction_summary': 'Transacciones de facturas vistas',
      'store_transaction': 'Transacciones',
      'store_locations': 'Localizaciones',
      'processing': 'Transacciones pendientes',
      'incomplete': 'Transacciones incompletas',
      'error': 'Transacciones con error',
      'done': 'Total'
    };
    final handleColors = {
      'processing': Colors.orange,
      'incomplete': Colors.orange,
      'error': Colors.red,
      'done': Colors.green
    };

    final processingQueueListCode = await db!.rawQuery('''
     SELECT count(*) as cant, code FROM $tableProcessingQueues GROUP BY code ORDER BY code DESC; 
    ''');

    final processingQueueListStatus = await db.rawQuery('''
     SELECT count(*) as cant, task FROM $tableProcessingQueues GROUP BY task ORDER BY task DESC; 
    ''');

    final totalTransactions = await db.rawQuery('''
     SELECT count(*) as cant FROM $tableProcessingQueues 
     WHERE code != 'store_transaction_start' and code != 'store_transaction_arrived' 
     and code != 'store_transaction_summary' and code != 'store_transaction'
     and code != 'store_locations' and task != 'incomplete' and task != 'error'
     and task != 'processing';
    ''');

    var pqc = [];
    var pqs = [];
    var pqa = [];

    for (var p in processingQueueListCode) {
      if (handleNames[p['code']] != null) {
        pqc.add({
          'name': handleNames[p['code']],
          'code': p['code'],
          'cant': p['cant']
        });
      }
    }
    for (var p in totalTransactions) {
      pqa.add({
        'name': 'Otras',
        'cant': p['cant'],
        'color': Colors.deepPurple,
      });
    }
    for (var p in processingQueueListStatus) {
      if (handleNames[p['task']] != null) {
        pqs.add({
          'name': handleNames[p['task']],
          'task': p['task'],
          'cant': p['cant'],
          'color': handleColors[p['task']]
        });
      }
    }
    yield [...pqc, ...pqs, ...pqa];
  }

  Future<int> countProcessingQueueIncompleteToTransactions() async {
    final db = await _appDatabase.streamDatabase;
    final processingQueueList = await db!.query(tableProcessingQueues,
        where: 'task != ? AND code != ? AND code != ? AND code != ?',
        whereArgs: [
          'done',
          'store_locations',
          'store_logout',
          'get_prediction'
        ]);
    final processingQueues = parseProcessingQueues(processingQueueList);
    return processingQueues.length;
  }

  Future<int> countAllTransactions() async {
    final db = await _appDatabase.streamDatabase;
    final result = await db!.query(tableProcessingQueues);
    return result.length;
  }

  Future<List<ProcessingQueue>> getAllProcessingQueuesIncomplete() async {
    final db = await _appDatabase.streamDatabase;

    final processingQueueList = await db!.query(tableProcessingQueues,
        where: 'task = ? or task = ? or task = ?',
        whereArgs: ['incomplete', 'error', 'processing']);
    final processingQueues = parseProcessingQueues(processingQueueList);
    return processingQueues;
  }

  Future<bool> validateIfProcessingQueueIsIncomplete() async {
    final db = await _appDatabase.streamDatabase;
    final processingQueueList = await db!.query(tableProcessingQueues,
        where:
            'task = ? OR task = ? OR task = ? AND code != ? AND code != ? AND code != ?',
        whereArgs: [
          'incomplete',
          'error',
          'processing'
              'store_locations',
          'store_logout',
          'get_prediction',
        ]);
    final processingQueues = parseProcessingQueues(processingQueueList);
    return processingQueues.isNotEmpty;
  }

  Future<int> insertProcessingQueue(ProcessingQueue processingQueue) {
    return _appDatabase.insert(tableProcessingQueues, processingQueue.toJson());
  }

  Future<int> updateProcessingQueue(ProcessingQueue processingQueue) {
    return _appDatabase.update(tableProcessingQueues, processingQueue.toJson(),
        'id', processingQueue.id!);
  }

  Future<void> emptyProcessingQueue() async {
    final db = await _appDatabase.streamDatabase;
    await db!.delete(tableProcessingQueues, where: 'code = "store_locations"');
    return Future.value();
  }

  Future<int> deleteProcessingQueueByDays() async {
    final db = await _appDatabase.streamDatabase;
    var today = DateTime.now();
    var limitDaysWork = _storageService.getInt('limit_days_works') ?? 3;
    var datesToValidate = today.subtract(Duration(days: limitDaysWork));
    List<Map<String, dynamic>> tasksToDelete;

    var formattedToday = DateTime(today.year, today.month, today.day);
    var formattedDatesToValidate = DateTime(
        datesToValidate.year, datesToValidate.month, datesToValidate.day);
    var formattedDatesToValidateStr =
        formattedDatesToValidate.toIso8601String().split('T')[0];

    tasksToDelete = await db!.query(
      tableProcessingQueues,
      where: 'substr(updated_at, 1, 10) <= ? and task = ?',
      whereArgs: [formattedDatesToValidateStr, 'done'],
    );

    for (var task in tasksToDelete) {
      var createdAt = DateTime.parse(task['updated_at']);
      var differenceInDays = formattedToday.difference(createdAt).inDays;
      if (differenceInDays > limitDaysWork) {
        await db.delete(
          tableProcessingQueues,
          where: 'id = ?',
          whereArgs: [task['id']],
        );
      }
    }

    return await db.delete(
      tableProcessingQueues,
      where: 'substr(updated_at, 1, 10) <= ? and task = ?',
      whereArgs: [formattedDatesToValidateStr, 'done'],
    );
  }
}
