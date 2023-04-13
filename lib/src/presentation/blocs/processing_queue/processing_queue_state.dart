part of 'processing_queue_bloc.dart';

abstract class ProcessingQueueState {}

class ProcessingQueueInitial extends ProcessingQueueState {}

class ProcessingQueueSuccess extends ProcessingQueueState {}

class ProcessingQueueFailure extends ProcessingQueueState {}