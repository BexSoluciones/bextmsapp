import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

//utils
import '../../../utils/resources/data_state.dart';

//domain
import '../../../domain/models/processing_queue.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/transaction_summary.dart';

//request
import '../../../domain/models/requests/transaction_request.dart';
import '../../../domain/models/requests/transaction_summary_request.dart';
//repositories
import '../../../domain/repositories/api_repository.dart';
import '../../../domain/repositories/database_repository.dart';
//abstract
import '../../../domain/abstracts/format_abstract.dart';


part 'processing_queue_event.dart';
part 'processing_queue_state.dart';

class ProcessingQueueBloc extends Bloc<ProcessingQueueEvent, ProcessingQueueState> with FormatDate {

  final DatabaseRepository _databaseRepository;
  final ApiRepository _apiRepository;

  final _processingQueueController = StreamController<List<ProcessingQueue>>.broadcast();
  final _addProcessingQueueController = StreamController<ProcessingQueue>.broadcast();


  Stream<List<ProcessingQueue>> get processingQueue => _processingQueueController.stream;

  StreamSink<List<ProcessingQueue>> get _inProcessingQueue => _processingQueueController.sink;
  StreamSink<ProcessingQueue> get inAddPq => _addProcessingQueueController.sink;

  ProcessingQueueBloc(this._databaseRepository, this._apiRepository) : super(ProcessingQueueInitial()) {
    on<ProcessingQueueAdd>(_add);
    on<ProcessingQueueObserve>(_observe);
    _addProcessingQueueController.stream.listen(_handleAddProcessingQueue);
    _processingQueueController.stream.listen(sendProcessingQueue);
  }

  Stream<List<ProcessingQueue>> get todos {
    return _databaseRepository.getAllProcessingQueues();
  }

  void dispose() {
    _processingQueueController.close();
    _addProcessingQueueController.close();
  }

  void _getProcessingQueue() async {
    final queues = await _databaseRepository.getAllProcessingQueuesIncomplete();
    _inProcessingQueue.add(queues);
  }

  void _add(event, emit) {
    _addProcessingQueueController.add(event.processingQueue);
    emit(ProcessingQueueSuccess());
  }

  void _observe(event, emit){
    _getProcessingQueue();
    emit(ProcessingQueueSuccess());
  }

  void _handleAddProcessingQueue(ProcessingQueue processingQueue) async {
    await _databaseRepository.insertProcessingQueue(processingQueue);
    _getProcessingQueue();
  }

  void sendProcessingQueue(List<ProcessingQueue> queues) async {
    await Future.forEach(queues, (queue) async {

      queue.updatedAt = now();

      switch (queue.code) {
        case 'YDASBDCUDD':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);

            final response =  await _apiRepository.start(request: TransactionRequest(Transaction.fromJson(body)));

            if(response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }

            await _databaseRepository.updateProcessingQueue(queue);

          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'LLKFNVLKNE':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);

            final response =  await _apiRepository.arrived(request: TransactionRequest(Transaction.fromJson(body)));

            if(response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }

            await _databaseRepository.updateProcessingQueue(queue);
          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'PISADJOFJO':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);

            final response =  await _apiRepository.summary(request: TransactionRequest(Transaction.fromJson(body)));

            if(response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }

            await _databaseRepository.updateProcessingQueue(queue);

          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'Z8RPOZDTJB':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);

            final response =  await _apiRepository.index(request: TransactionRequest(Transaction.fromJson(body)));

            if(response is DataSuccess) {
              queue.task = 'done';
            } else {
              queue.task = 'error';
              queue.error = response.error;
            }

            await _databaseRepository.updateProcessingQueue(queue);


          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'LIALIVNRAA':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);

            final res =  await _apiRepository.transaction(request: TransactionSummaryRequest(TransactionSummary.fromJson(body)));

            if(res is DataSuccess) {
              body['transaction_id'] = res.data!.transaction.id;
              final response =  await _apiRepository.product(request: TransactionSummaryRequest(TransactionSummary.fromJson(body)));

              if(response is DataSuccess) {
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
          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'VNAIANBTLM':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);



          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'EBSVAEKRJB':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);



          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'A48NDIVKJF':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);



          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case '90QQOINCQW':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);



          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'AB5A8E10Y3':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);



          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'SDAJBVKJAD':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);



          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'UWEBBEVWDC':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);



          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'OERINVOIEF':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);



          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;
        case 'QWPJCPQKNE':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);



          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }

          break;
        case 'ASJBVKJDFS':
          try {
            var body = jsonDecode(queue.body);

            queue.task = 'processing';
            await _databaseRepository.updateProcessingQueue(queue);



          } catch (e) {
            queue.task = 'error';
            queue.error = e.toString();
            await _databaseRepository.updateProcessingQueue(queue);
          }
          break;

        default:
      }
    });


  }
}