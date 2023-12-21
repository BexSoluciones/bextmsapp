part of 'processing_queue_bloc.dart';

abstract class ProcessingQueueState extends Equatable {
  final List<ProcessingQueue>? processingQueues;

  const ProcessingQueueState({this.processingQueues});

  @override
  List<Object> get props => [processingQueues!];
}

class ProcessingQueueInitial extends ProcessingQueueState {}

class ProcessingQueueSending extends ProcessingQueueState {}

class ProcessingQueueSuccess extends ProcessingQueueState {
  const ProcessingQueueSuccess({super.processingQueues});
}

class ProcessingQueueFailure extends ProcessingQueueState {}
