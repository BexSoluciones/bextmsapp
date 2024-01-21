part of 'processing_queue_bloc.dart';

enum ProcessingQueueStatus { initial, sending, loading, success, failure }

class ProcessingQueueState extends Equatable {
  final ProcessingQueueStatus? status;
  final List<ProcessingQueue>? processingQueues;
  final String? dropdownFilterValue;
  final String? dropdownStateValue;
  final String? error;

  const ProcessingQueueState(
      {this.processingQueues,
      this.status,
      this.dropdownFilterValue,
      this.dropdownStateValue,
      this.error});

  @override
  List<Object?> get props => [
        processingQueues,
        status,
        dropdownFilterValue,
        dropdownStateValue,
        error
      ];

  ProcessingQueueState copyWith(
          {ProcessingQueueStatus? status,
          List<ProcessingQueue>? processingQueues,
          String? dropdownFilterValue,
          String? dropdownStateValue,
          String? error}) =>
      ProcessingQueueState(
        status: status ?? this.status,
        processingQueues: processingQueues ?? this.processingQueues,
        dropdownFilterValue: dropdownFilterValue ?? this.dropdownFilterValue,
        dropdownStateValue: dropdownStateValue ?? this.dropdownStateValue,
        error: error ?? this.error,
      );
}
