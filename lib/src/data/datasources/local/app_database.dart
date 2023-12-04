import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite_migration/sqflite_migration.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:synchronized/synchronized.dart';

//utils
import '../../../utils/constants/strings.dart';

//models
import '../../../domain/models/work.dart';
import '../../../domain/models/warehouse.dart';
import '../../../domain/models/summary.dart';
import '../../../domain/models/transaction.dart' as t;
import '../../../domain/models/transaction_summary.dart';
import '../../../domain/models/location.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/models/reason.dart';
import '../../../domain/models/history_order.dart';
import '../../../domain/models/photo.dart';
import '../../../domain/models/client.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/news.dart';
import '../../../domain/models/notification.dart';
import '../../../domain/models/summary_report.dart';
import '../../../domain/models/transaction.dart';

//services
import '../../../locator.dart';
import '../../../services/storage.dart';

//daos
part '../local/dao/work_dao.dart';
part '../local/dao/summary_dao.dart';
part '../local/dao/transaction_dao.dart';
part '../local/dao/transaction_summary_dao.dart';
part '../local/dao/location_dao.dart';
part '../local/dao/processing_queue_dao.dart';
part '../local/dao/reason_dao.dart';
part '../local/dao/history_order_dao.dart';
part '../local/dao/warehouse_dao.dart';
part '../local/dao/photo_dao.dart';
part '../local/dao/client_dao.dart';
part '../local/dao/account_dao.dart';
part '../local/dao/news_dao.dart';
part '../local/dao/notification_dao.dart';



class AppDatabase {
  static BriteDatabase? _streamDatabase;

  // make this a singleton class
  // ignore: sort_constructors_first
  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();
  static var lock = Lock();

  static Database? _database;

  final initialScript = [
    '''
        CREATE TABLE $tableWorks (
        ${WorkFields.id} INTEGER PRIMARY KEY,
        ${WorkFields.workcode} TEXT DEFAULT NULL,
        ${WorkFields.numberCompany} INTEGER DEFAULT NULL,
        ${WorkFields.numberTransporter} TEXT DEFAULT NULL,
        ${WorkFields.nameTransporter} TEXT DEFAULT NULL,
        ${WorkFields.nameuser} TEXT DEFAULT NULL,
        ${WorkFields.date} TEXT DEFAULT NULL,
        ${WorkFields.datedelivery} TEXT DEFAULT NULL,
        ${WorkFields.tracking} TEXT DEFAULT NULL,
        ${WorkFields.amountPieces} INTEGER DEFAULT NULL,
        ${WorkFields.numberCustomer} TEXT DEFAULT NULL,
        ${WorkFields.type} TEXT DEFAULT NULL,
        ${WorkFields.codePlace} TEXT DEFAULT NULL,
        ${WorkFields.customer} TEXT DEFAULT NULL,
        ${WorkFields.address} TEXT DEFAULT NULL,
        ${WorkFields.cellphone} INTEGER DEFAULT 999,
        ${WorkFields.email} TEXT DEFAULT NULL,
        ${WorkFields.city} TEXT DEFAULT NULL,
        ${WorkFields.state} TEXT DEFAULT NULL,
        ${WorkFields.postalcode} TEXT DEFAULT NULL,
        ${WorkFields.latitude} TEXT DEFAULT NULL,
        ${WorkFields.longitude} TEXT DEFAULT NULL,
        ${WorkFields.observations} TEXT DEFAULT NULL,
        ${WorkFields.order} INTEGER DEFAULT 999,
        ${WorkFields.color} INTEGER DEFAULT NULL,
        ${WorkFields.status} TEXT DEFAULT NULL,
        ${WorkFields.isCalculated} BOOLEAN DEFAULT NULL,
        ${WorkFields.active} BOOLEAN DEFAULT NULL,
        ${WorkFields.duration} TEXT DEFAULT NULL,
        ${WorkFields.distance} TEXT DEFAULT NULL,
        ${WorkFields.zoneId} INTEGER DEFAULT NULL,
        ${WorkFields.warehouseId} INTEGER DEFAULT NULL,
        ${WorkFields.createdAt} TEXT DEFAULT NULL,
        ${WorkFields.updatedAt} TEXT DEFAULT NULL
      )
    ''',
    '''
      CREATE TABLE $tableSummaries (
        ${SummaryFields.id} INTEGER PRIMARY KEY,
        ${SummaryFields.workId} INTEGER DEFAULT NULL,
        ${SummaryFields.orderNumber} TEXT DEFAULT NULL,
        ${SummaryFields.type} TEXT DEFAULT NULL,
        ${SummaryFields.coditem} TEXT DEFAULT NULL,
        ${SummaryFields.codbar} TEXT DEFAULT NULL,
        ${SummaryFields.nameItem} TEXT DEFAULT NULL,
        ${SummaryFields.image} TEXT DEFAULT NULL,
        ${SummaryFields.amount} TEXT DEFAULT NULL,
        ${SummaryFields.cant} REAL DEFAULT NULL,
        ${SummaryFields.unitOfMeasurement} TEXT DEFAULT NULL,
        ${SummaryFields.nameOfMeasurement} TEXT DEFAULT NULL,
        ${SummaryFields.grandTotal} REAL DEFAULT NULL,
        ${SummaryFields.grandTotalCopy} REAL DEFAULT NULL,
        ${SummaryFields.price} REAL DEFAULT NULL,
        ${SummaryFields.typeOfCharge} TEXT DEFAULT NULL,
        ${SummaryFields.codeWarehouse} TEXT DEFAULT NULL,
        ${SummaryFields.operativeCenter} TEXT DEFAULT NULL,
        ${SummaryFields.costCenter} TEXT DEFAULT NULL,
        ${SummaryFields.manufacturingBatch} TEXT DEFAULT NULL,
        ${SummaryFields.typeItem} TEXT DEFAULT NULL,
        ${SummaryFields.typeTransaction} TEXT DEFAULT NULL,
        ${SummaryFields.evidences} TEXT DEFAULT NULL,
        ${SummaryFields.minus} INTEGER DEFAULT NULL,
        ${SummaryFields.status} TEXT DEFAULT NULL,
        ${SummaryFields.idPacking} TEXT DEFAULT NULL,
        ${SummaryFields.packing} TEXT DEFAULT NULL,
        ${SummaryFields.expedition} TEXT DEFAULT NULL,
        ${SummaryFields.createdAt} TEXT DEFAULT NULL,
        ${SummaryFields.updatedAt} TEXT DEFAULT NULL
      )
    ''',
    '''
       CREATE TABLE ${t.tableTransactions} (
        ${t.TransactionFields.id} INTEGER PRIMARY KEY,
        ${t.TransactionFields.workId} INTEGER DEFAULT NULL,
        ${t.TransactionFields.summaryId} INTEGER DEFAULT 999,
        ${t.TransactionFields.workcode} TEXT DEFAULT NULL,
        ${t.TransactionFields.orderNumber} TEXT DEFAULT NULL,
        ${t.TransactionFields.status} TEXT DEFAULT NULL,
        ${t.TransactionFields.codmotvis} TEXT DEFAULT NULL,
        ${t.TransactionFields.reason} TEXT DEFAULT NULL,
        ${t.TransactionFields.payments} TEXT DEFAULT NULL,
        ${t.TransactionFields.images} TEXT DEFAULT NULL,
        ${t.TransactionFields.observation} TEXT DEFAULT NULL,
        ${t.TransactionFields.delivery} TEXT DEFAULT NULL,
        ${t.TransactionFields.file} TEXT DEFAULT NULL,
        ${t.TransactionFields.operativeCenter} TEXT DEFAULT NULL,
        ${t.TransactionFields.firm} TEXT DEFAULT NULL,
        ${t.TransactionFields.start} TEXT DEFAULT NULL,
        ${t.TransactionFields.end} TEXT DEFAULT NULL,
        ${t.TransactionFields.latitude} TEXT DEFAULT NULL,
        ${t.TransactionFields.longitude} TEXT DEFAULT NULL,
        ${t.TransactionFields.historyId} INTEGER DEFAULT NULL
      )
    ''',
    '''
      CREATE TABLE $tableTransactionSummaries (
        ${TransactionSummaryFields.id} INTEGER PRIMARY KEY,
        ${TransactionSummaryFields.transactionId} INTEGER DEFAULT NULL,
        ${TransactionSummaryFields.summaryId} INTEGER DEFAULT NULL,
        ${TransactionSummaryFields.orderNumber} TEXT DEFAULT NULL,
        ${TransactionSummaryFields.workId} INTEGER DEFAULT 999,
        ${TransactionSummaryFields.numItems} INTEGER DEFAULT NULL,
        ${TransactionSummaryFields.productName} TEXT DEFAULT NULL,
        ${TransactionSummaryFields.codmotvis} TEXT DEFAULT NULL,
        ${TransactionSummaryFields.reason} TEXT DEFAULT NULL,
        ${TransactionSummaryFields.createdAt} TEXT DEFAULT NULL,
        ${TransactionSummaryFields.updatedAt} TEXT DEFAULT NULL
      )
    ''',
    '''
      CREATE TABLE $tableLocations ( 
        ${LocationFields.id} INTEGER PRIMARY KEY, 
        ${LocationFields.latitude} REAL DEFAULT NULL,
        ${LocationFields.longitude} REAL DEFAULT NULL,
        ${LocationFields.accuracy} REAL DEFAULT NULL,
        ${LocationFields.altitude} REAL DEFAULT NULL,
        ${LocationFields.speed} REAL DEFAULT NULL,
        ${LocationFields.speedAccuracy} REAL DEFAULT NULL,
        ${LocationFields.heading} REAL DEFAULT NULL,
        ${LocationFields.isMock} BOOLEAN DEFAULT NULL,
        ${LocationFields.userId} INTEGER DEFAULT NULL,
        ${LocationFields.time} TEXT DEFAULT NULL
      )  
    ''',
    '''
      CREATE TABLE $tableProcessingQueues (
        ${ProcessingQueueFields.id} INTEGER PRIMARY KEY,
        ${ProcessingQueueFields.body} TEXT DEFAULT NULL,
        ${ProcessingQueueFields.task} TEXT DEFAULT NULL,
        ${ProcessingQueueFields.code} TEXT DEFAULT NULL,
        ${ProcessingQueueFields.error} TEXT DEFAULT NULL,
        ${ProcessingQueueFields.createdAt} TEXT DEFAULT NULL,
        ${ProcessingQueueFields.updatedAt} TEXT DEFAULT NULL
      )
    ''',
    '''
      CREATE TABLE $tableReasons (
        ${ReasonFields.id} INTEGER PRIMARY KEY,
        ${ReasonFields.codmotvis} TEXT DEFAULT NULL,
        ${ReasonFields.nommotvis} TEXT DEFAULT NULL,
        ${ReasonFields.gendetmotvis} TEXT DEFAULT NULL,
        ${ReasonFields.tipocliente} TEXT DEFAULT NULL,
        ${ReasonFields.firm} INTEGER DEFAULT 999,
        ${ReasonFields.observation} INTEGER DEFAULT 999,
        ${ReasonFields.photo} INTEGER DEFAULT 999,
        ${ReasonFields.count} INTEGER DEFAULT 999,
        ${ReasonFields.createdAt} TEXT DEFAULT NULL,
        ${ReasonFields.updatedAt} TEXT DEFAULT NULL 
      )
    ''',
  ];

  final migrations = [
    '''
      CREATE INDEX workcode_index ON $tableWorks(${WorkFields.workcode});
    ''',
    '''
      CREATE TABLE $tablePhotos (
        ${PhotoFields.id} INTEGER PRIMARY KEY,
        ${PhotoFields.name} TEXT DEFAULT NULL,
        ${PhotoFields.path} TEXT DEFAULT NULL
      )
    ''',
    '''
      CREATE TABLE $tableClients (
        ${ClientFields.id} INTEGER PRIMARY KEY,
        ${ClientFields.nit} TEXT DEFAULT NULL,
        ${ClientFields.operativeCenter} TEXT DEFAULT NULL,
        ${ClientFields.latitude} TEXT DEFAULT NULL,
        ${ClientFields.longitude} TEXT DEFAULT NULL,
        ${ClientFields.action} TEXT DEFAULT NULL,
        ${ClientFields.userId} TEXT DEFAULT NULL
      )
    ''',
    '''
      CREATE TABLE $tableHistoryOrders (
        ${HistoryOrderFields.id} INTEGER PRIMARY KEY,
        ${HistoryOrderFields.workId} INTEGER NOT NULL,
        ${HistoryOrderFields.workcode} TEXT NOT NULL ,
        ${HistoryOrderFields.zoneId} INTEGER DEFAULT NULL,
        ${HistoryOrderFields.likelihood} REAL DEFAULT NULL,
        ${HistoryOrderFields.used} BOOLEAN DEFAULT NULL,
        ${HistoryOrderFields.listOrder} TEXT NOT NULL,
        ${HistoryOrderFields.works} TEXT NOT NULL,
        ${HistoryOrderFields.different} TEXT NOT NULL
      )
    ''',
    '''
      CREATE TABLE $tableNews (
        ${NewsFields.id} INTEGER PRIMARY KEY,
        ${NewsFields.userId} INTEGER NOT NULL,
        ${NewsFields.workId} INTEGER DEFAULT NULL,
        ${NewsFields.summaryId} INTEGER DEFAULT NULL,
        ${NewsFields.status} TEXT NOT NULL,
        ${NewsFields.nommotvis} TEXT NOT NULL,
        ${NewsFields.codmotvis} TEXT NOT NULL,
        ${NewsFields.latitude} TEXT NOT NULL,
        ${NewsFields.longitude} TEXT NOT NULL,
        ${NewsFields.images} TEXT DEFAULT NULL,
        ${NewsFields.firm} TEXT DEFAULT NULL,
        ${NewsFields.observation} TEXT DEFAULT NULL,
        ${NewsFields.createdAt} TEXT DEFAULT NULL,
        ${NewsFields.updatedAt} TEXT DEFAULT NULL)
    ''',
    '''
       CREATE TABLE $tableAccount (
        ${AccountFields.id} INTEGER PRIMARY KEY,
        ${AccountFields.idAccount} INTEGER NOT NULL ,
        ${AccountFields.accountId} INTEGER DEFAULT NULL,
        ${AccountFields.name} TEXT DEFAULT NULL,
        ${AccountFields.bankId} INTEGER DEFAULT NULL,
        ${AccountFields.accountNumber} INTEGER DEFAULT NULL,
        ${AccountFields.code_qr} TEXT DEFAULT NULL,
        ${AccountFields.createdAt} TEXT DEFAULT NULL
      )
    ''',
    '''
      CREATE TABLE $tableNotifications (
        ${NotificationFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${NotificationFields.id_from_server} TEXT,
        ${NotificationFields.title} TEXT,
        ${NotificationFields.body} TEXT,
        ${NotificationFields.date} TEXT,
        ${NotificationFields.with_click_action} TEXT,
        ${NotificationFields.read_at} TEXT 
      )
    ''',
    '''
      CREATE TABLE  polylines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workcode TEXT,
        polylines TEXT
      )
    ''',
    '''
      ALTER TABLE $tableProcessingQueues ADD COLUMN ${ProcessingQueueFields.relationId} INTEGER DEFAULT NULL
    ''',
    '''
      ALTER TABLE $tableProcessingQueues ADD COLUMN ${ProcessingQueueFields.relation} INTEGER DEFAULT NULL
    '''
  ];

  Future<Database> _initDatabase(databaseName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final config = MigrationConfig(
        initializationScript: initialScript, migrationScripts: migrations);
    final path = join(documentsDirectory.path, databaseName);
    return await openDatabaseWithMigration(path, config);
  }

  Future<Database?> get database async {
    var company = _storageService.getString('company');
    var dbName = company ?? databaseName;

    if (_database != null) return _database;
    await lock.synchronized(() async {
      if (_database == null) {
        if (dbName == '') {
          dbName = 'default';
        }
        _database = await _initDatabase('$dbName.db');
        _streamDatabase = BriteDatabase(_database!);
      }
    });
    return _database;
  }

  Future<BriteDatabase?> get streamDatabase async {
    await database;
    return _streamDatabase;
  }

  //INSERT METHODS
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.streamDatabase;
    return db!.insert(table, row);
  }

  //UPDATE METHODS
  Future<int> update(
      String table, Map<String, dynamic> value, String columnId, int id) async {
    final db = await instance.streamDatabase;
    return db!.update(table, value, where: '$columnId = ?', whereArgs: [id]);
  }

  // //DELETE METHODS
  Future<int> delete(String table, String columnId, int id) async {
    final db = await instance.streamDatabase;
    return db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  WorkDao get workDao => WorkDao(instance);

  WarehouseDao get warehouseDao => WarehouseDao(instance);

  SummaryDao get summaryDao => SummaryDao(instance);

  TransactionDao get transactionDao => TransactionDao(instance);

  ReasonDao get reasonDao => ReasonDao(instance);

  HistoryOrderDao get historyOrderDao => HistoryOrderDao(instance);

  ProcessingQueueDao get processingQueueDao => ProcessingQueueDao(instance);

  LocationDao get locationDao => LocationDao(instance);

  PhotoDao get photoDao => PhotoDao(instance);

  ClientDao get clientDao => ClientDao(instance);

  AccountDao get accountDao => AccountDao(instance);

  NewsDao get newsDao => NewsDao(instance);

  NotificationDao get notificationDao => NotificationDao(instance);

  void close() {
    _database = null;
    _streamDatabase!.close();
  }
}
