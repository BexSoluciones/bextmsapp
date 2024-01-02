part of 'processing_queue_bloc.dart';

enum ProcessingQueueStatus { initial, sending, loading, success, failure }

class ProcessingQueueState extends Equatable {
  final ProcessingQueueStatus? status;
  final List<ProcessingQueue>? processingQueues;

  const ProcessingQueueState({this.processingQueues, this.status});

  @override
  List<Object> get props => [processingQueues!, status!];

  ProcessingQueueState copyWith({
    ProcessingQueueStatus? status,
    List<ProcessingQueue>? processingQueues,
  }) =>
      ProcessingQueueState(
        status: status ?? this.status,
        processingQueues: processingQueues ?? this.processingQueues,
      );
}
