import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {

  NetworkBloc._() : super(NetworkInitial()) {
    on<NetworkObserve>(_observe);
    on<NetworkNotify>(_notifyStatus);
  }

  static final NetworkBloc _instance = NetworkBloc._();

  factory NetworkBloc() => _instance;

  void _observe(event, emit) {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      try {
        final response = await InternetAddress.lookup('example.com');

        if (result == ConnectivityResult.none) {
          NetworkBloc().add(NetworkNotify(isConnected: false));
        } else if(response.isNotEmpty && response[0].rawAddress.isNotEmpty) {
          NetworkBloc().add(NetworkNotify(isConnected: true));
        } else {
          NetworkBloc().add(NetworkNotify(isConnected: false));
        }
      } on SocketException catch (e) {
        NetworkBloc().add(NetworkNotify(isConnected: false));
      }

    });
  }

  void _notifyStatus(NetworkNotify event, emit) {
    event.isConnected ? emit(NetworkSuccess()) : emit(NetworkFailure());
  }
}