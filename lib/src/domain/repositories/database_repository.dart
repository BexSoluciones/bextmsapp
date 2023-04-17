import '../models/processing_queue.dart';
import '../models/transaction_summary.dart';
import '../models/work.dart';
import '../models/summary.dart';
import '../models/transaction.dart';
import '../models/reason.dart';
import '../models/history_order.dart';

abstract class DatabaseRepository {
  //WORKS
  Future<List<Work>> getAllWorks();
  Future<List<Work>> findAllWorksByWorkcode(String workcode);
  Future<List<Work>> findAllWorksPaginatedByWorkcode(String workcode, int page);
  Future<int> countAllWorksByWorkcode(String workcode);
  Future<int> insertWork(Work work);
  Future<int> updateWork(Work work);
  Future<void> insertWorks(List<Work> works);
  Future<void> emptyWorks();

  //SUMMARIES
  Future<List<Summary>> getAllSummariesByOrderNumber(int workId);
  Future<List<Summary>> getAllInventoryByOrderNumber(int workId, String orderNumber);
  Future<List<Summary>> getAllPackageByOrderNumber(int workId, String orderNumber);
  Future<List<Summary>> getAllSummariesByOrderNumberMoved(int workId, String orderNumber);
  Future<bool> resetCantSummaries(int workId, String orderNumber);
  Future<double> getTotalSummaries(int workId, String orderNumber);
  Future<int> insertSummary(Summary summary);
  Future<int> updateSummary(Summary summary);
  Future<void> insertSummaries(List<Summary> summaries);
  Future<void> emptySummaries();

  //TRANSACTIONS
  Future<List<Transaction>> getAllTransactions();
  Future<String?> getDiffTime(int workId);
  Future<int> insertTransaction(Transaction transaction);
  Future<int> insertTransactionSummary(TransactionSummary transactionSummary);
  Future<bool> validateTransaction(int workId);
  Future<bool> validateTransactionArrived(int workI, String status);
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

  //PROCESSING QUEUE
  Stream<List<ProcessingQueue>> getAllProcessingQueues();
  Future<List<ProcessingQueue>> getAllProcessingQueuesIncomplete();
  Future<int> updateProcessingQueue(ProcessingQueue processingQueue);
  Future<void> insertProcessingQueue(ProcessingQueue processingQueue);
  Future<void> emptyProcessingQueues();

  //HISTORY ORDER
  Future<HistoryOrder?> getHistoryOrder(String workcode, int zoneId);
}
