part of 'processing_queue_bloc.dart';

abstract class ProcessingQueueEvent {}

class ProcessingQueueAdd extends ProcessingQueueEvent {
  final ProcessingQueue processingQueue;
  ProcessingQueueAdd({ required this.processingQueue });
}

class ProcessingQueueObserve extends ProcessingQueueEvent {}
