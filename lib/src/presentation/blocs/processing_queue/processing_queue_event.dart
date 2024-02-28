part of 'processing_queue_bloc.dart';

abstract class ProcessingQueueEvent {}

class ProcessingQueueAdd extends ProcessingQueueEvent {
  final ProcessingQueue processingQueue;
  ProcessingQueueAdd({ required this.processingQueue});
}

class ProcessingQueueObserve extends ProcessingQueueEvent {}

class ProcessingQueueSender extends ProcessingQueueEvent {}

class ProcessingQueueCancel extends ProcessingQueueEvent {}

class ProcessingQueueAll extends ProcessingQueueEvent {}

class ProcessingQueueOne extends ProcessingQueueEvent {
  final int id;
  ProcessingQueueOne({ required this.id });
}

class ProcessingQueueSearchFilter extends ProcessingQueueEvent {
  final String? value;
  ProcessingQueueSearchFilter({ required this.value });
}

class ProcessingQueueSearchState extends ProcessingQueueEvent {
  final String? value;
  ProcessingQueueSearchState({ required this.value });
}