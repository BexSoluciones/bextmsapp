part of '../app_database.dart';

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
        whereArgs: ['incomplete', 'VNAIANBTLM', 'ASJBVKJDFS', 'AB5A8E10Y3']);
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
}
