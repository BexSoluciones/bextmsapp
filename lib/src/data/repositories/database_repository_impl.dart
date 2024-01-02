import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

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
import '../../domain/models/photo.dart';
import '../../domain/models/client.dart';
import '../../domain/models/account.dart';
import '../../domain/models/news.dart';
import '../../domain/models/summary_report.dart';
import '../../domain/models/notification.dart';
import '../../domain/models/note.dart';

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
  Future<int> updateStatusWork(String workcode, String status) async {
    return _appDatabase.workDao.updateStatusWork(workcode, status);
  }

  @override
  Future<void> insertWorks(List<Work> works) async {
    return _appDatabase.workDao.insertWorks(works);
  }

  @override
  Future<void> emptyWorks() async {
    return _appDatabase.workDao.emptyWorks();
  }

  @override
  Future<void> deleteWorksByWorkcode(String workcode) async {
    _appDatabase.workDao.deleteWorksByWorkcode(workcode);
  }

  //POLYLINES

  @override
  Future<int> insertPolylines(String workcode, List<LatLng> data) async {
    return _appDatabase.workDao.insertPolylines(workcode, data);
  }

  @override
  Future<List<LatLng>> getPolylines(String workcode) async {
    return _appDatabase.workDao.getPolylines(workcode);
  }

  //WAREHOUSES
  @override
  Future<List<Warehouse>> getAllWarehouses() async {
    return _appDatabase.warehouseDao.getAllWarehouses();
  }

  @override
  Future<Warehouse?> findWarehouse(int id) async {
    return _appDatabase.warehouseDao.findWarehouse(id);
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
  Future<List<Summary>> getAllSummariesByWorkcode(int workId, String customer) async {
    return _appDatabase.summaryDao.getAllSummariesByWorkcode(workId, customer);
  }

  @override
  Future<List<Summary>> getAllInventoryByOrderNumber(
      int workId, String orderNumber) async {
    return _appDatabase.summaryDao
        .getAllInventoryByOrderNumber(workId, orderNumber);
  }

  @override
  Future<List<Summary>> getAllInventoryByPackage(
      int workId, String orderNumber) async {
    return _appDatabase.summaryDao
        .getAllInventoryByPackage(workId, orderNumber);
  }

  @override
  Future<List<Summary>> getAllPackageByOrderNumber(
      int workId, String orderNumber) async {
    return _appDatabase.summaryDao
        .getAllPackageByOrderNumber(workId, orderNumber);
  }

  @override
  Future<List<Summary>> watchAllItemsPackage(
      String orderNumber, String packing, String idPacking) {
    return _appDatabase.summaryDao
        .watchAllItemsPackage(orderNumber, packing, idPacking);
  }

  @override
  Future<List<Summary>> getAllSummariesByOrderNumberMoved(
      int workId, String orderNumber) async {
    return _appDatabase.summaryDao
        .getAllSummariesByOrderNumberMoved(workId, orderNumber);
  }

  @override
  Future<int> getTotalPackageSummaries(String orderNumber) async {
    return _appDatabase.summaryDao.getTotalPackageSummaries(orderNumber);
  }

  @override
  Future<int> getTotalPackageSummariesLoose(String orderNumber) async {
    return _appDatabase.summaryDao.getTotalPackageSummariesLoose(orderNumber);
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

  @override
  Future<List<SummaryReport>> getSummaryReportsWithReasonOrRedelivery(
      String orderNumber) async {
    return _appDatabase.summaryDao
        .getSummaryReportsWithReasonOrRedelivery(orderNumber);
  }

  @override
  Future<void> deleteSummariesByWorkcode(String workcode) {
    return _appDatabase.summaryDao.deleteSummariesByWorkcode(workcode);
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
  Future<bool> validateTransactionSummary(
      String workcode, String orderNumber, String status) {
    return _appDatabase.transactionDao
        .validateTransactionSummary(workcode, orderNumber, status);
  }

  @override
  Future<bool> checkLastTransaction(String workcode) {
    return _appDatabase.transactionDao.checkLastTransaction(workcode);
  }

  @override
  Future<bool> checkLastProduct(int transactionId) {
    return _appDatabase.transactionDao.checkLastProduct(transactionId);
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
  Future<int> insertTransactionSummary(
      TransactionSummary transactionSummary) async {
    return _appDatabase.transactionDao
        .insertTransactionSummary(transactionSummary);
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

  @override
  Future<void> deleteTransactionsByWorkcode(String workcode) {
    return _appDatabase.transactionDao.deleteTransactionsByWorkcode(workcode);
  }

  @override
  Future<int> countLeftClients(String workcode) {
    return _appDatabase.transactionDao.countLeftClients(workcode);
  }

  @override
  Future<bool> verifyTransactionExistence(int workId, String orderNumber) {
    return _appDatabase.transactionDao
        .verifyTransactionExistence(workId, orderNumber);
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

  @override
  Future<int> insertNews(News news) async {
    return _appDatabase.reasonDao.insertNews(news);
  }

  //ACCOUNTS
  @override
  Future<List<Account>> getAllAccounts() async {
    return _appDatabase.accountDao.getAllAccounts();
  }

  @override
  Future<int> insertAccount(Account account) async {
    return _appDatabase.accountDao.insertAccount(account);
  }

  @override
  Future<int> updateAccount(Account account) async {
    return _appDatabase.accountDao.updateAccount(account);
  }

  @override
  Future<void> insertAccounts(List<Account> accounts) async {
    return _appDatabase.accountDao.insertAccounts(accounts);
  }

  @override
  Future<void> emptyAccounts() async {
    return _appDatabase.accountDao.emptyAccounts();
  }

  //PROCESSING QUEUE
  @override
  Future<List<ProcessingQueue>> getAllProcessingQueues(String? code, String? task) {
    return _appDatabase.processingQueueDao.getAllProcessingQueues(code, task);
  }

  @override
  Stream<List<ProcessingQueue>> watchAllProcessingQueues() {
    return _appDatabase.processingQueueDao.watchAllProcessingQueues();
  }

  @override
  Future<List<ProcessingQueue>> getAllProcessingQueuesIncomplete() async {
    return _appDatabase.processingQueueDao.getAllProcessingQueuesIncomplete();
  }

  @override
  Stream<List<Map<String, dynamic>>> countProcessingQueueIncompleteToTransactions() {
    return _appDatabase.processingQueueDao
        .countProcessingQueueIncompleteToTransactions();
  }

  @override
  Future<bool> validateIfProcessingQueueIsIncomplete() {
    return _appDatabase.processingQueueDao
        .validateIfProcessingQueueIsIncomplete();
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
  Future<bool> countLocationsManager() async {
    return _appDatabase.locationDao.countLocationsManager();
  }

  @override
  Future<String> getLocationsToSend() async {
    return _appDatabase.locationDao.getLocationsToSend();
  }

  @override
  Future<int?> updateLocationsManager() async {
    return _appDatabase.locationDao.updateLocationsManager();
  }

  @override
  Future<int> updateLocation(Location location) async {
    return _appDatabase.locationDao.updateLocation(location);
  }

  @override
  Future<int> insertLocation(Location location) async {
    return _appDatabase.locationDao.insertLocation(location);
  }

  @override
  Future<void> emptyLocations() async {
    return _appDatabase.locationDao.emptyLocations();
  }

  //PHOTOS
  @override
  Future<List<Photo>> getAllPhotos() async {
    return _appDatabase.photoDao.getAllPhotos();
  }

  @override
  Future<Photo?> findPhoto(String path) async {
    return _appDatabase.photoDao.findPhoto(path);
  }

  @override
  Future<int> insertPhoto(Photo photo) async {
    return _appDatabase.photoDao.insertPhoto(photo);
  }

  @override
  Future<int> updatePhoto(Photo photo) async {
    return _appDatabase.photoDao.updatePhoto(photo);
  }

  @override
  Future<int> deletePhoto(Photo photo) async {
    return _appDatabase.photoDao.deletePhoto(photo);
  }

  @override
  Future<int> deleteAll(int photoId) {
    return _appDatabase.photoDao.deleteAll(photoId);
  }

  @override
  Future<void> insertPhotos(List<Photo> photos) async {
    return _appDatabase.photoDao.insertPhotos(photos);
  }

  @override
  Future<void> emptyPhotos() async {
    return _appDatabase.photoDao.emptyPhotos();
  }

  //NOTES
  @override
  Future<List<Note>> getAllNotes() async {
    return _appDatabase.noteDao.getAllNotes();
  }

  @override
  Future<Note?> findNote(String zoneId) async {
    return _appDatabase.noteDao.findNote(zoneId);
  }

  @override
  Future<int> insertNote(Note note) async {
    return _appDatabase.noteDao.insertNote(note);
  }

  @override
  Future<int> updateNote(Note note) async {
    return _appDatabase.noteDao.updateNote(note);
  }

  @override
  Future<int> deleteNote(Note note) async {
    return _appDatabase.noteDao.deleteNote(note);
  }

  @override
  Future<void> insertNotes(List<Note> notes) async {
    return _appDatabase.noteDao.insertNotes(notes);
  }

  @override
  Future<void> emptyNotes() async {
    return _appDatabase.noteDao.emptyNotes();
  }

  //CLIENTS
  @override
  Stream<List<Client>> watchAllClients() {
    return _appDatabase.clientDao.watchAllClients();
  }

  @override
  Future<List<Client>> getAllClients() async {
    return _appDatabase.clientDao.getAllClients();
  }

  @override
  Future<bool> validateClient(int id) async {
    return _appDatabase.clientDao.validateClient(id);
  }

  @override
  Future<int> updateClient(Client client) async {
    return _appDatabase.clientDao.updateClient(client);
  }

  @override
  Future<int> insertClient(Client client) async {
    return _appDatabase.clientDao.insertClient(client);
  }

  @override
  Future<void> emptyClients() async {
    return _appDatabase.clientDao.emptyClients();
  }

  //HISTORY ORDER
  @override
  Future<HistoryOrder?> getHistoryOrder(String workcode, int zoneId) async {
    return _appDatabase.historyOrderDao.getHistoryOrder(workcode, zoneId);
  }

  @override
  Future<int> insertHistory(HistoryOrder historyOrder) async {
    return _appDatabase.historyOrderDao.insertHistory(historyOrder);
  }

  //WORK TYPE
  @override
  Future<WorkTypes?> getWorkTypesFromWorkcode(String workcode) async {
    return _appDatabase.transactionDao.getWorkTypesFromWorkcode(workcode);
  }

  //DELIVERY
  @override
  Future<List<WorkAdditional>> getClientsResJetDel(
      String workcode, String reason) async {
    return _appDatabase.transactionDao.getClientsResJetDel(workcode, reason);
  }

  @override
  Future<double?> countTotalCollectionWorks() async {
    return _appDatabase.transactionDao.countTotalCollectionWorks();
  }

  @override
  Future<double> countTotalRespawnWorksByWorkcode(
      String workcode, String reason) async {
    return _appDatabase.summaryDao
        .countTotalRespawnWorksByWorkcode(workcode, reason);
  }

  @override
  Future<List<SummaryReport>> getSummaryReportsWithReturnOrRedelivery(
      String orderNumber) async {
    return _appDatabase.summaryDao
        .getSummaryReportsWithReturnOrRedelivery(orderNumber);
  }

  @override
  Future<List<SummaryReport>> getSummaryReportsWithDelivery(
      String orderNumber) {
    return _appDatabase.summaryDao.getSummaryReportsWithDelivery(orderNumber);
  }

  //NOTIFICATION
  @override
  Future<int> insertNotification(PushNotification notification) {
    return _appDatabase.notificationDao
        .insert(tableNotifications, notification.toJson());
  }

  @override
  Future<List<PushNotification>> getNotifications() {
    return _appDatabase.notificationDao.getNotifications();
  }

  @override
  Future<void> updateNotification(int notificationId, String readAt) {
    return _appDatabase.notificationDao
        .updateNotification(notificationId, readAt);
  }

  @override
  Future<int?> countAllUnreadNotifications() {
    return _appDatabase.notificationDao.countAllUnreadNotifications();
  }

  //DELETE BY DAYS
  @override
  Future<void> deleteProcessingQueueByDays() {
    return _appDatabase.processingQueueDao.deleteProcessingQueueByDays();
  }

  @override
  Future<void> deleteLocationsByDays() {
    return _appDatabase.locationDao.deleteLocationsByDays();
  }

  @override
  Future<void> deleteNotificationsByDays() {
    return _appDatabase.notificationDao.deleteNotificationsByDays();
  }

  @override
  Future<void> deleteTransactionByDays() {
    return _appDatabase.transactionDao.deleteTransactionByDays();
  }

  // initialize and close methods go here
  Future init() async {
    await _appDatabase.database;
    return Future.value();
  }

  void close() {
    _appDatabase.close();
  }

  @override
  Future<sqflite.Database?> get() async {
    return await _appDatabase.database;
  }

  @override
  Future<bool> listenForTableChanges(
      String table, String column, String value) {
    return _appDatabase.listenForTableChanges(table, column, value);
  }
}
