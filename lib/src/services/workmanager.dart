import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

//core
import '../../../core/helpers/index.dart';
//utils

import '../utils/resources/data_state.dart';
import '../utils/constants/strings.dart';

//domain
import '../domain/models/isolate.dart';
import '../domain/models/transaction.dart';
import '../domain/models/transaction_summary.dart';
import '../domain/models/processing_queue.dart';
import '../domain/models/client.dart';
import '../domain/repositories/database_repository.dart';
import '../domain/repositories/api_repository.dart';
import '../domain/abstracts/format_abstract.dart';
//request
import '../domain/models/requests/client_request.dart';
import '../domain/models/requests/locations_request.dart';
import '../domain/models/requests/logout_request.dart';
import '../domain/models/requests/reason_m_request.dart';
import '../domain/models/requests/send_token.dart';
import '../domain/models/requests/status_request.dart';
import '../domain/models/requests/transaction_request.dart';
import '../domain/models/requests/transaction_summary_request.dart';

//services
import '../locator.dart';
import '../services/storage.dart';
import '../services/logger.dart';

class WorkmanagerService with FormatDate {
  static WorkmanagerService? _instance;
  static Workmanager? _preferences;

  final helperFunction = HelperFunctions();

  static Future<WorkmanagerService?> getInstance() async {
    _instance ??= WorkmanagerService();
    _preferences = Workmanager();
    return _instance;
  }

  Future<void> heavyTask(IsolateModel model) async {
    for (var i = 0; i < model.iteration; i++) {
      await model.functions[i]();
    }
  }

  initialize(
    Function callbackDispatcher,
  ) {
    if (_preferences == null) return;
    _preferences?.initialize(callbackDispatcher, isInDebugMode: true);
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  void display(
      String title, String body, HelperFunctions helperFunctions) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        "01",
        "Bex Deliveries",
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ));

      await FlutterLocalNotificationsPlugin()
          .show(id, title, body, notificationDetails);
    } on Exception catch (e, stackTrace) {
      helperFunctions.handleException(e, stackTrace);
    }
  }

  executeTask(
      LocalStorageService storageService,
      DatabaseRepository databaseRepository,
      ApiRepository apiRepository) {
    if (_preferences == null) return;
    _preferences?.executeTask((task, inputData) async {
      int? totalExecutions;

      try {
        totalExecutions = storageService.getInt("totalExecutions");
        storageService.setInt("totalExecutions",
            totalExecutions == null ? 1 : totalExecutions + 1);
      } catch (err) {
        throw Exception(err);
      }

      switch (task) {
        case 'get_processing_queues_and_handle':
          try {
            return sendProcessing(
               storageService,
              databaseRepository,
               apiRepository);
          } catch (error, stackTrace) {
            logDebug(headerDeveloperLogger, 'error----$error');
            helperFunction.handleException(error, stackTrace);
            return Future.value(false);
          }
        case 'transaction_start':
          try {
            final isConnected = await checkConnection();
            if (isConnected) {
              final Transaction transactionJson =
                  Transaction.fromJson(jsonDecode(inputData?['array']));
              final response = await apiRepository.start(
                  request: TransactionRequest(transactionJson));
              if (response is DataSuccess) {
                return Future.value(true);
              } else {
                return Future.value(false);
              }
            } else {
              return Future.value(false);
            }
          } catch (error, stackTrace) {
            helperFunction.handleException(error, stackTrace);
            return Future.value(false);
          }
        case 'transaction_arrived':
          try {
            final isConnected = await checkConnection();
            if (isConnected) {
              final Transaction transactionJson =
                  Transaction.fromJson(jsonDecode(inputData?['array']));
              final response = await apiRepository.arrived(
                  request: TransactionRequest(transactionJson));
              if (response is DataSuccess) {
                return Future.value(true);
              } else {
                return Future.value(false);
              }
            } else {
              return Future.value(false);
            }
          } catch (error, stackTrace) {
            helperFunction.handleException(error, stackTrace);
            return Future.value(false);
          }
        case 'transaction_summary':
          try {
            final isConnected = await checkConnection();
            if (isConnected) {
              final Transaction transactionJson =
                  Transaction.fromJson(jsonDecode(inputData?['array']));
              final response = await apiRepository.summary(
                  request: TransactionRequest(transactionJson));
              if (response is DataSuccess) {
                return Future.value(true);
              } else {
                return Future.value(false);
              }
            } else {
              return Future.value(false);
            }
          } catch (error, stackTrace) {
            helperFunction.handleException(error, stackTrace);
            return Future.value(false);
          }
        case 'transaction':
          try {
            final isConnected = await checkConnection();
            if (isConnected) {
              final Transaction transactionJson =
                  Transaction.fromJson(jsonDecode(inputData?['array']));
              final response = await apiRepository.index(
                  request: TransactionRequest(transactionJson));
              if (response is DataSuccess) {
                return Future.value(true);
              } else {
                return Future.value(false);
              }
            } else {
              return Future.value(false);
            }
          } catch (error, stackTrace) {
            helperFunction.handleException(error, stackTrace);
            return Future.value(false);
          }
        case 'get_works_completed_and_send':
          try {
            var works = await databaseRepository.completeWorks();

            if (works != null && works.isNotEmpty) {
              for (var workcode in works) {
                final response = await apiRepository.status(
                    request: StatusRequest(workcode, 'complete'));

                if (response is DataFailed) {
                  helperFunction.handleException(
                      'workcode $workcode no complete',
                      StackTrace.fromString(response!.error!));
                }
              }

              return Future.value(true);
            } else {
              return Future.value(true);
            }
          } catch (error, stackTrace) {
            helperFunction.handleException(error, stackTrace);
            return Future.value(false);
          }
        // case Workmanager.iOSBackgroundTask:
        //   Directory? tempDir = await getTemporaryDirectory();
        //   String? tempPath = tempDir.path;
        //   break;
      }

      return Future.value(true);
    });
  }

  registerPeriodicTask(String id, String name, Duration? frequency) {
    if (_preferences == null) return;
    _preferences?.registerPeriodicTask(id, name,
        frequency: frequency,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(networkType: NetworkType.connected));
  }

  registerOneOffTask(String id, String name, Map<String, dynamic> data) {
    if (_preferences == null) return;
    _preferences?.registerOneOffTask(id, name,
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(seconds: 20),
        inputData: data,
        constraints: Constraints(networkType: NetworkType.connected));
  }

  Future<bool> sendProcessing(
      LocalStorageService storageService,
      DatabaseRepository databaseRepository,
      ApiRepository apiRepository) async {
    final isConnected = await checkConnection();
    final queues = await databaseRepository.getAllProcessingQueuesIncomplete();
    if (isConnected && queues.isNotEmpty) {
      var futures = <Function>[];
      for (var queue in queues) {
        futures.add(() => sendProcessingQueue(queue, storageService,
            databaseRepository, apiRepository, helperFunction));
      }
      var isolateModel = IsolateModel(futures, futures.length);
      return await heavyTask(isolateModel).then((values) async {
        return true;
      }).catchError((error, stackTrace) {
        helperFunction.handleException(error, stackTrace);
        return false;
      });
    } else if (queues.isNotEmpty) {
      display(
          'Atención!',
          'No tienes conexción a intenet y tienes ${queues.length} transacciones pendientes.',
          helperFunction);

      return Future.value(true);
    } else {
      return Future.value(true);
    }
  }

  Future<void> sendProcessingQueue(
      ProcessingQueue queue,
      LocalStorageService storageService,
      DatabaseRepository databaseRepository,
      ApiRepository apiRepository,
      HelperFunctions helperFunction) async {
    logDebug(headerDeveloperLogger, 'sending');
    logDebug(headerDeveloperLogger, queue.code);
    queue.updatedAt = now();

    switch (queue.code) {
      case 'store_transaction_start':
        try {
          var body = jsonDecode(queue.body!);
          body['end'] = now();
          queue.body = jsonEncode(body);
          queue.task = 'processing';
          await databaseRepository.updateProcessingQueue(queue);
          final response = await apiRepository.start(
              request: TransactionRequest(Transaction.fromJson(body)));
          if (response is DataSuccess) {
            queue.task = 'done';
          } else {
            queue.task = 'error';
            body['start'] = now();
            queue.body = jsonEncode(body);
            queue.error = response?.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          var body = jsonDecode(queue.body!);
          body['start'] = now();
          queue.body = jsonEncode(body);
          queue.error = e.toString();
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      case 'store_transaction_arrived':
        try {
          var body = jsonDecode(queue.body!);
          body['end'] = now();
          queue.body = jsonEncode(body);
          queue.task = 'processing';
          await databaseRepository.updateProcessingQueue(queue);
          final response = await apiRepository.arrived(
              request: TransactionRequest(Transaction.fromJson(body)));
          if (response is DataSuccess) {
            queue.task = 'done';
          } else {
            queue.task = 'error';
            body['start'] = now();
            queue.body = jsonEncode(body);
            queue.error = response?.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          var body = jsonDecode(queue.body!);
          body['start'] = now();
          queue.body = jsonEncode(body);
          queue.error = e.toString();
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }

        break;
      case 'store_transaction_summary':
        try {
          var body = jsonDecode(queue.body!);
          body['end'] = now();
          queue.body = jsonEncode(body);
          queue.task = 'processing';
          await databaseRepository.updateProcessingQueue(queue);
          final response = await apiRepository.summary(
              request: TransactionRequest(Transaction.fromJson(body)));
          if (response is DataSuccess) {
            queue.task = 'done';
          } else {
            queue.task = 'error';
            body['start'] = now();
            queue.body = jsonEncode(body);
            queue.error = response?.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          var body = jsonDecode(queue.body!);
          body['start'] = now();
          queue.body = jsonEncode(body);
          queue.error = e.toString();
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      case 'store_transaction':
        try {
          var body = jsonDecode(queue.body!);
          body['end'] = now();
          queue.body = jsonEncode(body);
          queue.task = 'processing';
          await databaseRepository.updateProcessingQueue(queue);
          final response = await apiRepository.index(
              request: TransactionRequest(Transaction.fromJson(body)));
          if (response is DataSuccess) {
            queue.task = 'done';
          } else {
            queue.task = 'error';
            body['start'] = now();
            queue.body = jsonEncode(body);
            queue.error = response!.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      case 'store_transaction_product':
        var body = jsonDecode(queue.body!);
        try {
          queue.task = 'processing';
          await databaseRepository.updateProcessingQueue(queue);
          final res = await apiRepository.transaction(
              request:
                  TransactionSummaryRequest(TransactionSummary.fromJson(body)));
          if (res is DataSuccess) {
            body['transaction_id'] = res?.data!.transaction.id;
            final response = await apiRepository.product(
                request: TransactionSummaryRequest(
                    TransactionSummary.fromJson(body)));
            if (response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response?.error;
            }
          } else {
            queue.task = 'error';
            body['start'] = now();
            queue.body = jsonEncode(body);
            queue.error = res?.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          body['start'] = now();
          queue.body = jsonEncode(body);
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      case 'store_locations':
        try {
          queue.task = 'processing';
          final response = await apiRepository.locations(
              request: LocationsRequest(queue.body!));
          if (response is DataSuccess) {
            queue.task = 'done';
          } else {
            queue.task = 'error';
            queue.error = response.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }

        break;
      case 'store_news':
        try {
          queue.task = 'processing';
          final response =
              await apiRepository.reason(request: ReasonMRequest(queue));
          if (response is DataSuccess) {
            queue.task = 'done';
          } else {
            queue.task = 'error';
            queue.error = response.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      case 'store_work_status':
        try {
          var body = jsonDecode(queue.body!);
          queue.task = 'processing';
          await databaseRepository.updateProcessingQueue(queue);
          final response = await apiRepository.status(
              request: StatusRequest(body['workcode'], body['status']));
          if (response is DataSuccess) {
            queue.task = 'done';
          } else {
            queue.task = 'error';
            queue.error = response?.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      case 'update_client':
        try {
          var body = jsonDecode(queue.body!);
          queue.task = 'processing';
          await databaseRepository.updateProcessingQueue(queue);
          final response = await apiRepository.georeference(
              request: ClientRequest(Client.fromJson(body)));
          if (response is DataSuccess) {
            queue.task = 'done';
          } else {
            queue.task = 'error';
            queue.error = response.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }

        break;
      case 'post_logout':
        try {
          queue.task = 'processing';
          await databaseRepository.updateProcessingQueue(queue);
          var response = await apiRepository.logout(request: LogoutRequest());
          if (response is DataSuccess) {
            queue.task = 'done';
          } else {
            queue.task = 'error';
            queue.error = response.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;

      case 'post_firebase_token':
        try {
          var body = jsonDecode(queue.body!);
          queue.task = 'processing';
          await databaseRepository.updateProcessingQueue(queue);
          var response = await apiRepository.sendFCMToken(
              request: SendTokenRequest(
                  int.parse(body['user_id']), body['fcm_token']));
          if (response is DataSuccess) {
            queue.task = 'done';
          } else {
            queue.task = 'error';
            queue.error = response.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          helperFunction.handleException(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      default:
    }
  }
}
