import 'package:bexdeliveries/src/domain/models/notification.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:bexdeliveries/src/domain/models/summary_report.dart';

import '../models/processing_queue.dart';
import '../models/transaction_summary.dart';
import '../models/work.dart';
import '../models/summary.dart';
import '../models/transaction.dart';
import '../models/reason.dart';
import '../models/history_order.dart';
import '../models/warehouse.dart';
import '../models/location.dart';
import '../models/photo.dart';
import '../models/client.dart';
import '../models/account.dart';

abstract class DatabaseRepository {
  //WORKS
  Future<List<Work>> getAllWorks();
  Future<List<Work>> findAllWorksByWorkcode(String workcode);
  Future<List<Work>> findAllWorksPaginatedByWorkcode(String workcode, int page);
  Future<int> countAllWorksByWorkcode(String workcode);
  Future<int> insertWork(Work work);
  Future<int> updateWork(Work work);
  Future<int> updateStatusWork(String workcode, String status);
  Future<void> insertWorks(List<Work> works);
  Future<void> emptyWorks();

  //WORKTYPE
  Future<WorkTypes?> getWorkTypesFromWorkcode(String workcode);

  //DELIVER
  Future<List<WorkAdditional>> getClientsResJetDel(String workcode,String reason);

  //WAREHOUSES
  Future<Warehouse?> findWarehouse(Warehouse warehouse);
  Future<int> insertWarehouse(Warehouse warehouse);
  Future<int> updateWarehouse(Warehouse warehouse);
  Future<void> insertWarehouses(List<Warehouse> warehouses);
  Future<void> emptyWarehouses();

  //SUMMARIES
  Future<List<Summary>> getAllSummariesByOrderNumber(int workId);
  Future<List<Summary>> getAllInventoryByOrderNumber(int workId, String orderNumber);
  Future<List<Summary>> getAllPackageByOrderNumber(int workId, String orderNumber);
  Future<List<Summary>> getAllSummariesByOrderNumberMoved(int workId, String orderNumber);
  Future<List<SummaryReport>> getSummaryReportsWithReasonOrRedelivery(String orderNumber);
  Future<List<SummaryReport>> getSummaryReportsWithReturnOrRedelivery(String orderNumber);
  Future<List<SummaryReport>> getSummaryReportsWithDelivery(String orderNumber);
  Future<double> countTotalRespawnWorksByWorkcode(String workcode,String reason);
  Future<bool> resetCantSummaries(int workId, String orderNumber);
  Future<double> getTotalSummaries(int workId, String orderNumber);
  Future<int> insertSummary(Summary summary);
  Future<int> updateSummary(Summary summary);
  Future<void> insertSummaries(List<Summary> summaries);
  Future<void> emptySummaries();

  //TRANSACTIONS
  Future<List<Transaction>> getAllTransactions();
  Future<String?> getDiffTime(int workId);
  Future<double?> countTotalCollectionWorks();
  Future<int> insertTransaction(Transaction transaction);
  Future<int> insertTransactionSummary(TransactionSummary transactionSummary);
  Future<bool> validateTransaction(int workId);
  Future<bool> validateTransactionArrived(int workId, String status);
  Future<bool> validateTransactionSummary(String workcode, String orderNumber, String status);
  Future<bool> checkLastTransaction(String workcode);
  Future<int> updateTransaction(Transaction transaction);
  Future<void> insertTransactions(List<Transaction> transactions);
  Future<void> emptyTransactions();

  //REASONS
  Future<List<Reason>> getAllReasons();
  Future<Reason?> findReason(String name);
  Future<int> insertReason(Reason reason);
  Future<int> updateReason(Reason reason);
  Future<void> insertReasons(List<Reason> reasons);
  Future<void> emptyReasons();

  //ACCOUNTS
  Future<List<Account>> getAllAccounts();
  Future<int> insertAccount(Account account);
  Future<int> updateAccount(Account account);
  Future<void> insertAccounts(List<Account> accounts);
  Future<void> emptyAccounts();

  //PROCESSING QUEUE
  Stream<List<ProcessingQueue>> getAllProcessingQueues();
  Future<List<ProcessingQueue>> getAllProcessingQueuesIncomplete();
  Future<int> countProcessingQueueIncompleteToTransactions();
  Future<int> updateProcessingQueue(ProcessingQueue processingQueue);
  Future<void> insertProcessingQueue(ProcessingQueue processingQueue);
  Future<void> emptyProcessingQueues();

  //LOCATIONS
  Stream<List<Location>> watchAllLocations();
  Future<List<Location>> getAllLocations();
  Future<Location?> getLastLocation();
  Future<int> updateLocation(Location location);
  Future<void> insertLocation(Location location);
  Future<void> emptyLocations();

  //PHOTOS
  Future<List<Photo>> getAllPhotos();
  Future<Photo?> findPhoto(String path);
  Future<int> insertPhoto(Photo photo);
  Future<int> updatePhoto(Photo photo);
  Future<int> deletePhoto(Photo photo);
  Future<void> insertPhotos(List<Photo> photos);
  Future<void> emptyPhotos();

  //PHOTOS
  Stream<List<Client>> watchAllClients();
  Future<List<Client>> getAllClients();
  Future<int> insertClient(Client client);
  Future<int> updateClient(Client client);
  Future<void> emptyClients();

  //HISTORY ORDER
  Future<HistoryOrder?> getHistoryOrder(String workcode, int zoneId);


  //ROOT
  Future<sqflite.Database?> get();


  //NOTIFICATIONS
  Future<int> insertNotification(PushNotification notification);
  Future<List<PushNotification>> getNotifications();
  Future<void> updateNotification(int notificationId, String readAt);
  Future<int?> countAllUnreadNotifications();

  //POLYLINES
  Future<int> insertPolylines(String workcode,List<LatLng> data);
  Future<List<LatLng>> getPolylines(String workcode);

}
