import 'dart:async';
import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//utils
import '../../../utils/constants/strings.dart';
import '../../../utils/resources/data_state.dart';

//domain
import '../../../domain/models/processing_queue.dart';
import '../../../domain/models/isolate.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/client.dart';
import '../../../domain/models/transaction_summary.dart';
import '../../../domain/models/requests/prediction_request.dart';

//request
import '../../../domain/models/requests/transaction_request.dart';
import '../../../domain/models/requests/transaction_summary_request.dart';
import '../../../domain/models/requests/logout_request.dart';
import '../../../domain/models/requests/status_request.dart';
import '../../../domain/models/requests/client_request.dart';
import '../../../domain/models/requests/send_token.dart';
//repositories
import '../../../domain/repositories/api_repository.dart';
import '../../../domain/repositories/database_repository.dart';
//abstract
import '../../../domain/abstracts/format_abstract.dart';

//service
import '../../../services/logger.dart';

part 'processing_queue_event.dart';
part 'processing_queue_state.dart';

class ProcessingQueueBloc
    extends Bloc<ProcessingQueueEvent, ProcessingQueueState> with FormatDate {
  final DatabaseRepository _databaseRepository;
  final ApiRepository _apiRepository;

  final _processingQueueController =
      StreamController<List<ProcessingQueue>>.broadcast();
  final _addProcessingQueueController =
      StreamController<ProcessingQueue>.broadcast();

  Stream<List<ProcessingQueue>> get processingQueue =>
      _processingQueueController.stream;
  StreamSink<List<ProcessingQueue>> get _inProcessingQueue =>
      _processingQueueController.sink;
  StreamSink<ProcessingQueue> get inAddPq => _addProcessingQueueController.sink;

  ProcessingQueueBloc(this._databaseRepository, this._apiRepository)
      : super(ProcessingQueueInitial()) {
    on<ProcessingQueueAdd>(_add);
    on<ProcessingQueueObserve>(_observe);
    on<ProcessingQueueSender>(_sender);
    on<ProcessingQueueCancel>(_cancel);
    _addProcessingQueueController.stream.listen((p) async {
      await _databaseRepository.insertProcessingQueue(p);
      await Future.value([
        _getProcessingQueue(),
        validateIfServiceIsCompleted(p),
      ]);
    }, onError: (error) {
      if (kDebugMode) {
        print('error');
        print(error);
      }
    }, onDone: () {
      if (kDebugMode) {
        print('done');
      }
    });

    _processingQueueController.stream.listen(sendProcessingQueue);
  }

  static void heavyTask(IsolateModel model) {
    for (var i = 0; i < model.iteration; i++) {
      model.functions[i];
    }
  }

  Stream get resolve {
    return Stream.periodic(const Duration(seconds: 30), (int value) async {
      final timer0 = logTimerStart(headerLogger, 'Starting...', level: LogLevel.info);
      var result = await _databaseRepository.listenForTableChanges('works', 'status', 'complete');
      logDebugFine(headerLogger, result.toString());
      if(result) await _getProcessingQueue();
      logTimerStop(headerLogger, timer0, 'Initialization completed',
          level: LogLevel.success);
    });
  }

  Stream<List<ProcessingQueue>> get todos {
    return _databaseRepository.getAllProcessingQueues();
  }

  Future<int> countProcessingQueueIncompleteToTransactions() {
    return _databaseRepository.countProcessingQueueIncompleteToTransactions();
  }

  void dispose() {
    _processingQueueController.close();
    _addProcessingQueueController.close();
  }

  Future<void> _getProcessingQueue() async {
    logDebugFine(headerLogger, 'activating pq');
    final queues = await _databaseRepository.getAllProcessingQueuesIncomplete();
    _inProcessingQueue.add(queues);
  }

  void _add(event, emit) {
    _addProcessingQueueController.add(event.processingQueue);
    emit(ProcessingQueueSuccess());
  }

  void _observe(event, emit) {
    _getProcessingQueue();
    emit(ProcessingQueueSuccess());
  }

  void _sender(event, emit) async {
    emit(ProcessingQueueSending());
    await _getProcessingQueue()
        .whenComplete(() => emit(ProcessingQueueSuccess()));
  }

  void _cancel(event, emit) {
    emit(ProcessingQueueSuccess());
  }

  void sendProcessingQueue(List<ProcessingQueue> queues) async {
    await Future.forEach(queues, (queue) async {
      queue.updatedAt = now();

      switch (queue.code) {
        case 'store_transaction_start':
          try {
            var body = jsonDecode(queue.body);
            body['end'] = now();
            queue.body = jsonEncode(body);
            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);
            final response = await _apiRepository.start(
                request: TransactionRequest(Transaction.fromJson(body)));
            if (response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'store_transaction_arrived':
          try {
            var body = jsonDecode(queue.body);
            body['end'] = now();
            queue.body = jsonEncode(body);
            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);
            final response = await _apiRepository.arrived(
                request: TransactionRequest(Transaction.fromJson(body)));
            if (response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'store_transaction_summary':
          try {
            var body = jsonDecode(queue.body);
            body['end'] = now();
            queue.body = jsonEncode(body);
            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);
            final response = await _apiRepository.summary(
                request: TransactionRequest(Transaction.fromJson(body)));
            if (response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'store_transaction':
          try {
            var body = jsonDecode(queue.body);
            body['end'] = now();
            queue.body = jsonEncode(body);
            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);
            final response = await _apiRepository.index(
                request: TransactionRequest(Transaction.fromJson(body)));
            if (response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'store_transaction_product':
          var body = jsonDecode(queue.body);
          try {
            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);
            final res = await _apiRepository.transaction(
                request: TransactionSummaryRequest(
                    TransactionSummary.fromJson(body)));
            if (res is DataSuccess) {
              body['transaction_id'] = res.data!.transaction.id;
              final response = await _apiRepository.product(
                  request: TransactionSummaryRequest(
                      TransactionSummary.fromJson(body)));
              if (response is DataSuccess) {
                queue.task = 'done';
              } else {
                queue.task = 'error';
                queue.error = response.error;
              }
            } else {
              queue.task = 'error';
              queue.error = res.error;
            }
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            body['start'] = now();
            queue.body = jsonEncode(body);
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'store_locations':
          try {
            var body = jsonDecode(queue.body);
            queue.task = 'processing';
            //TODO:: [Heider Zapa ] do

            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'store_work_status':
          try {
            var body = jsonDecode(queue.body);
            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);
            final response = await _apiRepository.status(
                request: StatusRequest(body['workcode'], body['status']));
            if (response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'store_history_order':
          try {
            var body = jsonDecode(queue.body);
            queue.task = 'processing';
            //TODO:: [Heider Zapa ] do
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'update_history_order':
          try {
            var body = jsonDecode(queue.body);
            queue.task = 'processing';
            //TODO:: [Heider Zapa ] do
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'get_prediction':
          try {
            var body = jsonDecode(queue.body);
            queue.task = 'processing';
            final response = await _apiRepository.prediction(
                request: PredictionRequest(
                    int.parse(body['zone_id']), body['workcode']));
            if (response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'post_new_routing':
          try {
            var body = jsonDecode(queue.body);
            queue.task = 'processing';
            //TODO:: [Heider Zapa ] do
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'post_update_client':
          try {
            var body = jsonDecode(queue.body);
            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);
            final response = await _apiRepository.georeference(
                request: ClientRequest(Client.fromJson(body)));
            if (response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'post_logout':
          try {
            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);
            var response =
                await _apiRepository.logout(request: LogoutRequest());
            if (response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;

        case 'post_firebase_token':
          try {
            var body = jsonDecode(queue.body);
            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);
            var response = await _apiRepository.sendFCMToken(
                request: SendTokenRequest(
                    int.parse(body['user_id']), body['fcm_token']));
            if (response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        default:
      }
    });
  }

  Future<void> validateIfServiceIsCompleted(ProcessingQueue p) async {
    try {
      if (p.code == 'store_transaction') {
        //TODO:: [Heider Zapa] check if partial
        var workcode = jsonDecode(p.body)['workcode'];
        var isLast = await _databaseRepository.checkLastTransaction(workcode);
        if (isLast) {
          var processingQueue = ProcessingQueue(
            body: jsonEncode({'workcode': workcode, 'status': 'complete'}),
            task: 'incomplete',
            code: 'store_work_status',
            createdAt: now(),
            updatedAt: now(),
          );
          await _databaseRepository.insertProcessingQueue(processingQueue);

          await _databaseRepository.updateStatusWork(workcode, 'complete');
        }
      }
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
  }
}
