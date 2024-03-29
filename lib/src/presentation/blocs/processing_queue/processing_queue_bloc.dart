import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//core
import '../../../../core/helpers/index.dart';

//blocs
import '../network/network_bloc.dart';

//utils
import '../../../utils/constants/strings.dart';
import '../../../utils/resources/data_state.dart';

//domain
import '../../../domain/models/processing_queue.dart';
import '../../../domain/models/isolate.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/client.dart';
import '../../../domain/models/history_order.dart';
import '../../../domain/models/transaction_summary.dart';
import '../../../domain/models/requests/prediction_request.dart';

//request
import '../../../domain/models/requests/transaction_request.dart';
import '../../../domain/models/requests/transaction_summary_request.dart';
import '../../../domain/models/requests/logout_request.dart';
import '../../../domain/models/requests/status_request.dart';
import '../../../domain/models/requests/client_request.dart';
import '../../../domain/models/requests/send_token.dart';
import '../../../domain/models/requests/locations_request.dart';
import '../../../domain/models/requests/reason_m_request.dart';
import '../../../domain/models/requests/history_order_saved_request.dart';
import '../../../domain/models/requests/history_order_updated_request.dart';
import '../../../domain/models/requests/routing_request.dart';
//repositories
import '../../../domain/repositories/api_repository.dart';
import '../../../domain/repositories/database_repository.dart';
//abstract
import '../../../domain/abstracts/format_abstract.dart';

//service
import '../../../services/logger.dart';
import '../../../services/storage.dart';

part 'processing_queue_event.dart';
part 'processing_queue_state.dart';

class ProcessingQueueBloc
    extends Bloc<ProcessingQueueEvent, ProcessingQueueState> with FormatDate {
  final DatabaseRepository databaseRepository;
  final ApiRepository apiRepository;
  final NetworkBloc? networkBloc;
  final LocalStorageService storageService;

  final helperFunctions = HelperFunctions();

  ProcessingQueueBloc(
      this.databaseRepository, this.apiRepository, this.networkBloc, this.storageService)
      : super(const ProcessingQueueState(
            status: ProcessingQueueStatus.initial,
            processingQueues: [],
            dropdownFilterValue: 'all',
            dropdownStateValue: 'all')) {
    on<ProcessingQueueAdd>(_add);
    on<ProcessingQueueOne>(_one);
    on<ProcessingQueueObserve>(_observe);
    on<ProcessingQueueSender>(_sender);
    on<ProcessingQueueCancel>(_cancel);
    on<ProcessingQueueAll>(_all);
    on<ProcessingQueueSearchFilter>(_searchFilter);
    on<ProcessingQueueSearchState>(_searchState);
  }

  final itemsFilter = [
    {'key': 'all', 'value': 'Todos'},
    {'key': 'processing', 'value': 'Procesando'},
    {'key': 'error', 'value': 'Error'},
    {'key': 'incomplete', 'value': 'Incompleto'},
    {'key': 'done', 'value': 'Enviado'},
  ];

  final itemsState = [
    {'key': 'all', 'value': 'Todos'},
    {'key': 'store_transaction_start', 'value': 'Transacción inicio'},
    {'key': 'store_transaction_arrived', 'value': 'Transacción de llegada'},
    {'key': 'store_transaction_summary', 'value': 'Transacción de factura'},
    {'key': 'store_transaction', 'value': 'Transacción'},
    {'key': 'store_transaction_product', 'value': 'Transacción de producto'},
    {'key': 'store_locations', 'value': 'Localizaciones'},
    {'key': 'store_work_status', 'value': 'Estado de la planilla'},
  ];

  static void heavyTask(IsolateModel model) {
    for (var i = 0; i < model.iteration; i++) {
      model.functions[i];
    }
  }

  Stream get resolve {
    return Stream.periodic(const Duration(seconds: 30), (int value) async {
      final timer0 = logTimerStart(headerDeveloperLogger, 'Starting...',
          level: LogLevel.info);
      await _getProcessingQueue();
      logTimerStop(headerDeveloperLogger, timer0, 'Initialization completed',
          level: LogLevel.success);
      return true;
    });
  }

  Stream<List<ProcessingQueue>> get todos {
    return databaseRepository.watchAllProcessingQueues();
  }

  Future<int> countProcessingQueueIncompleteToTransactions() {
    return databaseRepository.countProcessingQueueIncompleteToTransactions();
  }

  Stream<List<Map<String, dynamic>>>
      getProcessingQueueIncompleteToTransactions() {
    return databaseRepository.getProcessingQueueIncompleteToTransactions();
  }

  Future<List<ProcessingQueue>> getData(int? page, int? limit) {
    return databaseRepository.getAllProcessingQueuesPaginated(page, limit);
  }

  Future<void> _getProcessingQueue() async {
    if (networkBloc != null && networkBloc?.state is NetworkSuccess) {
      var queues = await databaseRepository.getAllProcessingQueuesIncomplete();
      sendProcessingQueues(queues);
    }
  }

  void _one(ProcessingQueueOne event, emit) async {
    emit(state.copyWith(status: ProcessingQueueStatus.loading));
    var processingQueue = await databaseRepository.findProcessingQueue(event.id);
    emit(state.copyWith(
        status: ProcessingQueueStatus.success,
        processingQueue: processingQueue));
  }

  void _all(event, emit) async {
    var processingQueues =
        await databaseRepository.getAllProcessingQueues(null, null);
    emit(state.copyWith(
        status: ProcessingQueueStatus.success,
        processingQueues: processingQueues));
  }

  void _add(ProcessingQueueAdd event, emit) async {
    logDebug(headerDeveloperLogger, 'add event dispatch');
    var id =
        await databaseRepository.insertProcessingQueue(event.processingQueue);
    event.processingQueue.id = id;
    if (networkBloc != null && networkBloc?.state is NetworkSuccess) {
      if (event.processingQueue.code != 'store_transaction_product') {
        await Future.value([
          sendProcessingQueue(event.processingQueue),
          validateIfServiceIsCompleted(event.processingQueue),
        ]);
      } else {
        await Future.value([
          validateIfServiceIsCompleted(event.processingQueue),
        ]);
      }
    }

    emit(state.copyWith(status: ProcessingQueueStatus.success));
  }

  void _observe(event, emit) {
    if (networkBloc != null &&
        networkBloc?.state is NetworkSuccess &&
        state.status == ProcessingQueueStatus.success) {
      _getProcessingQueue();
    }
    emit(state.copyWith(status: ProcessingQueueStatus.success));
  }

  void _sender(event, emit) async {
    emit(state.copyWith(status: ProcessingQueueStatus.sending));
    await _getProcessingQueue().whenComplete(
        () => emit(state.copyWith(status: ProcessingQueueStatus.success)));
  }

  void _cancel(event, emit) {
    emit(state.copyWith(status: ProcessingQueueStatus.success));
  }

  void _searchFilter(ProcessingQueueSearchFilter event, emit) async {
    var processingQueues = <ProcessingQueue>[];
    if (event.value != 'all') {
      processingQueues = await databaseRepository.getAllProcessingQueues(
          state.dropdownFilterValue, state.dropdownFilterValue);
    } else {
      processingQueues =
          await databaseRepository.getAllProcessingQueues(null, null);
    }

    emit(state.copyWith(
        dropdownFilterValue: event.value,
        status: ProcessingQueueStatus.success,
        processingQueues: processingQueues));
  }

  void _searchState(ProcessingQueueSearchState event, emit) async {
    var processingQueues = <ProcessingQueue>[];
    if (event.value != 'all') {
      processingQueues = await databaseRepository.getAllProcessingQueues(
          state.dropdownFilterValue, state.dropdownFilterValue);
    } else {
      processingQueues =
          await databaseRepository.getAllProcessingQueues(null, null);
    }
    emit(state.copyWith(
        dropdownStateValue: event.value,
        status: ProcessingQueueStatus.success,
        processingQueues: processingQueues));
  }

  void sendProcessingQueues(List<ProcessingQueue> queues) async {
    await Future.forEach(queues, (queue) async {
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'store_transaction_product':
          var body = jsonDecode(queue.body!);
          try {
            queue.task = 'processing';
            await databaseRepository.updateProcessingQueue(queue);
            final res = await apiRepository.transaction(
                request: TransactionSummaryRequest(
                    TransactionSummary.fromJson(body)));
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
              queue.error = response!.error;
            }
            await databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
              queue.error = response!.error;
            }
            await databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'store_history_order':
          try {
            var body = jsonDecode(queue.body!);
            queue.task = 'processing';
            final response = await apiRepository.historyOrderSaved(
                request: HistoryOrderSavedRequest(body['work_id']));
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'update_history_order':
          try {
            var body = jsonDecode(queue.body!);
            queue.task = 'processing';
            final response = await apiRepository.historyOrderUpdated(
                request: HistoryOrderUpdatedRequest(body['workcode'], 1));
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'get_prediction':
          try {
            var body = jsonDecode(queue.body!);
            queue.task = 'processing';
            final response = await apiRepository.prediction(
                request: PredictionRequest(body['zone_id'], body['workcode']));
            if (response is DataSuccess) {
              var prediction = response.data;

              if (prediction != null) {
                var historyOrder = HistoryOrder(
                    id: prediction.id,
                    workId: prediction.workId!,
                    workcode: body['workcode'],
                    zoneId: prediction.zoneId,
                    listOrder: prediction.listOrders!,
                    works: prediction.works!,
                    different: prediction.differences!,
                    likelihood: prediction.likelihood!,
                    used: prediction.used);

                await databaseRepository.insertHistory(historyOrder);

                if (historyOrder.used!) {
                  storageService.setBool(
                      '${historyOrder.workcode}-usedHistoric', true);
                  storageService.setBool(
                      '${historyOrder.workcode}-recentlyUpdated', true);
                  storageService.setBool(
                      '${historyOrder.workcode}-showAgain', true);
                  storageService.setBool(
                      '${historyOrder.workcode}-oneOrMoreFinished', true);

                  await helperFunctions.useHistoricFromSync(
                      workcode: historyOrder.workcode!,
                      historyId: historyOrder.id!,
                      queue: queue);
                } else {
                  storageService.setBool(
                      '${historyOrder.workcode}-showAgain', false);
                }
              }

              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'post_new_routing':
          try {
            var body = jsonDecode(queue.body!);
            queue.task = 'processing';
            final response = await apiRepository.routing(
                request: RoutingRequest(body['history_id'], body['workcode']));
            if (response is DataSuccess) {
              await databaseRepository.insertWorks(response.data!.works);
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }
            await databaseRepository.updateProcessingQueue(queue);
          } catch (e, stackTrace) {
            queue.task = 'error';
            queue.error = e.toString();
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'post_logout':
          try {
            queue.task = 'processing';
            await databaseRepository.updateProcessingQueue(queue);
            var response =
                await apiRepository.logout(request: LogoutRequest());
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
            await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            await databaseRepository.updateProcessingQueue(queue);
          }
          break;
        default:
      }
    });
  }

  void sendProcessingQueue(ProcessingQueue queue) async {
    logDebug(headerDeveloperLogger, 'send processing queue event dispatch');
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
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
            queue.error = response?.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
            queue.error = response!.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
            queue.error = response!.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      case 'store_history_order':
        try {
          var body = jsonDecode(queue.body!);
          queue.task = 'processing';
          final response = await apiRepository.historyOrderSaved(
              request: HistoryOrderSavedRequest(body['work_id']));
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
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      case 'update_history_order':
        try {
          var body = jsonDecode(queue.body!);
          queue.task = 'processing';
          final response = await apiRepository.historyOrderUpdated(
              request: HistoryOrderUpdatedRequest(body['workcode'], 1));
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
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      case 'get_prediction':
        try {
          var body = jsonDecode(queue.body!);
          queue.task = 'processing';
          final response = await apiRepository.prediction(
              request: PredictionRequest(body['zone_id'], body['workcode']));
          if (response is DataSuccess) {
            var prediction = response.data;

            if (prediction != null) {
              var historyOrder = HistoryOrder(
                  id: prediction.id,
                  workId: prediction.workId!,
                  workcode: body['workcode'],
                  zoneId: prediction.zoneId,
                  listOrder: prediction.listOrders!,
                  works: prediction.works!,
                  different: prediction.differences!,
                  likelihood: prediction.likelihood!,
                  used: prediction.used);

              await databaseRepository.insertHistory(historyOrder);

              if (historyOrder.used!) {
                storageService.setBool(
                    '${historyOrder.workcode}-usedHistoric', true);
                storageService.setBool(
                    '${historyOrder.workcode}-recentlyUpdated', true);
                storageService.setBool(
                    '${historyOrder.workcode}-showAgain', true);
                storageService.setBool(
                    '${historyOrder.workcode}-oneOrMoreFinished', true);

                await helperFunctions.useHistoricFromSync(
                    workcode: historyOrder.workcode!,
                    historyId: historyOrder.id!,
                    queue: queue);
              } else {
                storageService.setBool(
                    '${historyOrder.workcode}-showAgain', false);
              }
            }

            queue.task = 'done';
          } else {
            queue.task = 'error';
            queue.error = response.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      case 'post_new_routing':
        try {
          var body = jsonDecode(queue.body!);
          queue.task = 'processing';
          final response = await apiRepository.routing(
              request: RoutingRequest(body['history_id'], body['workcode']));
          if (response is DataSuccess) {
            await databaseRepository.insertWorks(response.data!.works);
            queue.task = 'done';
          } else {
            queue.task = 'error';
            queue.error = response.error;
          }
          await databaseRepository.updateProcessingQueue(queue);
        } catch (e, stackTrace) {
          queue.task = 'error';
          queue.error = e.toString();
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
          await databaseRepository.updateProcessingQueue(queue);
        }
        break;
      default:
    }
  }

  Future<void> validateIfServiceIsCompleted(ProcessingQueue p) async {
    try {
      if (p.code == 'store_transaction' ||
          p.code == 'store_transaction_product') {
        var body = jsonDecode(p.body!);
        String? workcode = body['workcode'];
        if (workcode != null) {
          var isLast = await databaseRepository.checkLastTransaction(workcode);
          if (isLast) {
            var processingQueue = ProcessingQueue(
              body: jsonEncode({'workcode': workcode, 'status': 'complete'}),
              task: 'incomplete',
              code: 'store_work_status',
              createdAt: now(),
              updatedAt: now(),
            );
            await databaseRepository.insertProcessingQueue(processingQueue);
            var cmh = storageService.getBool('can_make_history');
            if (cmh == null || cmh == false) {
              await databaseRepository.updateStatusWork(workcode, 'complete');
            }
          }
        }
      }
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
  }
}
