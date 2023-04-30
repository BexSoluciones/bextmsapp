import '../../domain/repositories/database_repository.dart';
import '../datasources/local/app_database.dart';

//models
import '../../domain/models/work.dart';
import '../../domain/models/summary.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/transaction_summary.dart';
import '../../domain/models/reason.dart';
import '../../domain/models/processing_queue.dart';
import '../../domain/models/history_order.dart';
import '../../domain/models/warehouse.dart';
import '../../domain/models/location.dart';

class DatabaseRepositoryImpl implements DatabaseRepository {
  final AppDatabase _appDatabase;

  DatabaseRepositoryImpl(this._appDatabase);

  //WORKS
  @override
  Future<List<Work>> getAllWorks() async {
    return _appDatabase.workDao.getAllWorks();
  }

  @override
  Future<List<Work>> findAllWorksByWorkcode(String workcode) async {
    return _appDatabase.workDao.findAllWorksByWorkcode(workcode);
  }

  @override
  Future<int> countAllWorksByWorkcode(String workcode) async {
    return _appDatabase.workDao.countAllWorksByWorkcode(workcode);
  }

  @override
  Future<List<Work>> findAllWorksPaginatedByWorkcode(
      String workcode, int page) async {
    return _appDatabase.workDao.findAllWorksPaginatedByWorkcode(workcode, page);
  }

  @override
  Future<int> insertWork(Work work) async {
    return _appDatabase.workDao.insertWork(work);
  }

  @override
  Future<int> updateWork(Work work) async {
    return _appDatabase.workDao.updateWork(work);
  }

  @override
  Future<void> insertWorks(List<Work> works) async {
    return _appDatabase.workDao.insertWorks(works);
  }

  @override
  Future<void> emptyWorks() async {
    return _appDatabase.workDao.emptyWorks();
  }

  //WAREHOUSES
  @override
  Future<Warehouse?> findWarehouse(Warehouse warehouse) async {
    return _appDatabase.warehouseDao.findWarehouse(warehouse);
  }

  @override
  Future<int> insertWarehouse(Warehouse warehouse) async {
    return _appDatabase.warehouseDao.insertWarehouse(warehouse);
  }

  @override
  Future<int> updateWarehouse(Warehouse warehouse) async {
    return _appDatabase.warehouseDao.updateWarehouse(warehouse);
  }

  @override
  Future<void> insertWarehouses(List<Warehouse> warehouses) async {
    return _appDatabase.warehouseDao.insertWarehouses(warehouses);
  }

  @override
  Future<void> emptyWarehouses() async {
    return _appDatabase.warehouseDao.emptyWarehouses();
  }

  //SUMMARIES
  @override
  Future<List<Summary>> getAllSummariesByOrderNumber(int workId) async {
    return _appDatabase.summaryDao.getAllSummariesByOrderNumber(workId);
  }

  @override
  Future<List<Summary>> getAllInventoryByOrderNumber(
      int workId, String orderNumber) async {
    return _appDatabase.summaryDao
        .getAllInventoryByOrderNumber(workId, orderNumber);
  }

  @override
  Future<List<Summary>> getAllPackageByOrderNumber(
      int workId, String orderNumber) async {
    return _appDatabase.summaryDao
        .getAllPackageByOrderNumber(workId, orderNumber);
  }

  @override
  Future<List<Summary>> getAllSummariesByOrderNumberMoved(
      int workId, String orderNumber) async {
    return _appDatabase.summaryDao
        .getAllSummariesByOrderNumberMoved(workId, orderNumber);
  }

  @override
  Future<bool> resetCantSummaries(int workId, String orderNumber) {
    return _appDatabase.summaryDao.resetCantSummaries(workId, orderNumber);
  }

  @override
  Future<double> getTotalSummaries(int workId, String orderNumber) async {
    return _appDatabase.summaryDao.getTotalSummaries(workId, orderNumber);
  }

  @override
  Future<int> insertSummary(Summary summary) async {
    return _appDatabase.summaryDao.insertSummary(summary);
  }

  @override
  Future<int> updateSummary(Summary summary) async {
    return _appDatabase.summaryDao.updateSummary(summary);
  }

  @override
  Future<void> insertSummaries(List<Summary> summaries) async {
    return _appDatabase.summaryDao.insertSummaries(summaries);
  }

  @override
  Future<void> emptySummaries() async {
    return _appDatabase.summaryDao.emptySummaries();
  }

  //TRANSACTIONS
  @override
  Future<List<Transaction>> getAllTransactions() async {
    return _appDatabase.transactionDao.getAllTransactions();
  }

  @override
  Future<bool> validateTransaction(int workId) {
    return _appDatabase.transactionDao.validateTransaction(workId);
  }

  @override
  Future<bool> validateTransactionArrived(int workId, String status) {
    return _appDatabase.transactionDao
        .validateTransactionArrived(workId, status);
  }

  @override
  Future<bool> validateTransactionSummary(String workcode, String orderNumber, String status) {
    return _appDatabase.transactionDao
        .validateTransactionSummary(workcode, orderNumber, status);
  }

  @override
  Future<String?> getDiffTime(int workId) async {
    return _appDatabase.transactionDao.getDiffTime(workId);
  }

  @override
  Future<int> insertTransaction(Transaction transaction) async {
    return _appDatabase.transactionDao.insertTransaction(transaction);
  }

  @override
  Future<int> insertTransactionSummary(TransactionSummary transactionSummary) async {
    return _appDatabase.transactionDao.insertTransactionSummary(transactionSummary);
  }

  @override
  Future<int> updateTransaction(Transaction transaction) async {
    return _appDatabase.transactionDao.updateTransaction(transaction);
  }

  @override
  Future<void> insertTransactions(List<Transaction> transactions) async {
    return _appDatabase.transactionDao.insertTransactions(transactions);
  }

  @override
  Future<void> emptyTransactions() async {
    return _appDatabase.transactionDao.emptyTransactions();
  }

  //REASONS
  @override
  Future<List<Reason>> getAllReasons() async {
    return _appDatabase.reasonDao.getAllReasons();
  }

  @override
  Future<Reason?> findReason(String name) async {
    return _appDatabase.reasonDao.findReason(name);
  }

  @override
  Future<int> insertReason(Reason reason) async {
    return _appDatabase.reasonDao.insertReason(reason);
  }

  @override
  Future<int> updateReason(Reason reason) async {
    return _appDatabase.reasonDao.updateReason(reason);
  }

  @override
  Future<void> insertReasons(List<Reason> reasons) async {
    return _appDatabase.reasonDao.insertReasons(reasons);
  }

  @override
  Future<void> emptyReasons() async {
    return _appDatabase.reasonDao.emptyReasons();
  }

  //PROCESSING QUEUE
  @override
  Stream<List<ProcessingQueue>> getAllProcessingQueues() {
    return _appDatabase.processingQueueDao.getAllProcessingQueues();
  }

  @override
  Future<List<ProcessingQueue>> getAllProcessingQueuesIncomplete() async {
    return _appDatabase.processingQueueDao.getAllProcessingQueuesIncomplete();
  }

  @override
  Future<int> countProcessingQueueIncompleteToTransactions() {
    return _appDatabase.processingQueueDao.countProcessingQueueIncompleteToTransactions();
  }

  @override
  Future<int> updateProcessingQueue(ProcessingQueue processingQueue) async {
    return _appDatabase.processingQueueDao
        .updateProcessingQueue(processingQueue);
  }

  @override
  Future<int> insertProcessingQueue(ProcessingQueue processingQueue) async {
    return _appDatabase.processingQueueDao
        .insertProcessingQueue(processingQueue);
  }

  @override
  Future<void> emptyProcessingQueues() async {
    return _appDatabase.processingQueueDao.emptyProcessingQueue();
  }

  //LOCATIONS
  @override
  Stream<List<Location>> watchAllLocations() {
    return _appDatabase.locationDao.watchAllLocations();
  }

  @override
  Future<List<Location>> getAllLocations() async {
    return _appDatabase.locationDao.getAllLocations();
  }

  @override
  Future<Location?> getLastLocation() async {
    return _appDatabase.locationDao.getLastLocation();
  }

  @override
  Future<int> updateLocation(Location location) async {
    return _appDatabase.locationDao
        .updateLocation(location);
  }

  @override
  Future<int> insertLocation(Location location) async {
    return _appDatabase.locationDao
        .insertLocation(location);
  }

  @override
  Future<void> emptyLocations() async {
    return _appDatabase.locationDao.emptyLocations();
  }

  //HISTORY ORDER
  @override
  Future<HistoryOrder?> getHistoryOrder(String workcode, int zoneId) async {
    return _appDatabase.historyOrderDao.getHistoryOrder(workcode, zoneId);
  }

  // initialize and close methods go here
  Future init() async {
    await _appDatabase.database;
    return Future.value();
  }

  void close() {
    _appDatabase.close();
  }
}
