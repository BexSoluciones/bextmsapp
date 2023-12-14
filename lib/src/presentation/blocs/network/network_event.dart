part of 'network_bloc.dart';

abstract class NetworkEvent {}

class NetworkObserve extends NetworkEvent {
  NetworkObserve();
}

class NetworkNotify extends NetworkEvent {
  final bool isConnected;

  NetworkNotify({this.isConnected = false});
}