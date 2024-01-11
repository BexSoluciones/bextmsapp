import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:bexdeliveries/core/helpers/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

//domain
import '../domain/models/transaction.dart';
import '../domain/models/error.dart';
import '../domain/repositories/database_repository.dart';

//services
import '../locator.dart';
import '../services/storage.dart';

class WorkmanagerService {
  static WorkmanagerService? _instance;
  static Workmanager? _preferences;

  static Future<WorkmanagerService?> getInstance() async {
    _instance ??= WorkmanagerService();
    _preferences = Workmanager();
    return _instance;
  }

  executeTask() {
    if (_preferences == null) return;
    _preferences?.executeTask((task, inputData) async {
      int? totalExecutions;

      final storageService = locator<LocalStorageService>();
      final databaseRepository = locator<DatabaseRepository>();

      final helperFunction = HelperFunctions();

      try {
        totalExecutions = storageService.getInt("totalExecutions");
        storageService.setInt("totalExecutions",
            totalExecutions == null ? 1 : totalExecutions + 1);
      } catch (err) {
        throw Exception(err);
      }

      switch (task) {
        case 'login':
          try {
            //TODO: [ Heider Zapa ] call processing queue
            return Future.value(true);
          } catch (error, stackTrace) {
            helperFunction.handleException(error, stackTrace);
            return Future.value(false);
          }
        case 'transaction':
          try {
            final Transaction transactionJson =
                Transaction.fromJson(jsonDecode(inputData?['array']));
            log(transactionJson.toString());
            //TODO: [ Heider Zapa ] call processing queue
            helperFunction.handleException('error exitoso', StackTrace.fromString(transactionJson.toString()));
            return Future.value(true);
          } catch (error, stackTrace) {
            helperFunction.handleException(error, stackTrace);
            return Future.value(false);
          }
        case Workmanager.iOSBackgroundTask:
          Directory? tempDir = await getTemporaryDirectory();
          String? tempPath = tempDir.path;
          break;
      }

      return Future.value(true);
    });
  }
}
