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

  Stream<List<ProcessingQueue>> getAllProcessingQueues() async* {
    final db = await _appDatabase.streamDatabase;
    final processingQueueList = await db!.query(tableProcessingQueues);
    final processingQueues = parseProcessingQueues(processingQueueList);
    yield processingQueues;
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
        where: 'task = ? AND code != ? AND code != ? AND code != ?',
        whereArgs: [
          'incomplete',
          'store_locations',
          'store_logout',
          'get_prediction'
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
    await db!.delete(tableProcessingQueues, where: 'code = "VNAIANBTLM"');
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
    var formattedTodayStr = formattedToday.toIso8601String().split('T')[0];
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
