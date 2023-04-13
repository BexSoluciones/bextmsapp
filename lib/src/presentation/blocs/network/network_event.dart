part of 'network_bloc.dart';

abstract class NetworkEvent {}

class NetworkObserve extends NetworkEvent {
  final ProcessingQueueBloc processingQueueBloc;

  NetworkObserve({ required this.processingQueueBloc });
}

class NetworkNotify extends NetworkEvent {
  final bool isConnected;

  NetworkNotify({this.isConnected = false});
}