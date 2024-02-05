import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bexdeliveries/src/presentation/blocs/network/network_bloc.dart';

void main() {
  test('initial state for network', () {
    expect(NetworkBloc().state,
        isA<NetworkInitial>()
    );
  });

  group('NetworkConnectivity', () {
    blocTest<NetworkBloc, NetworkState>(
      'Should initialize with connected network',
      build: () => NetworkBloc(),
      act: (NetworkBloc bloc) => bloc.add(NetworkNotify(isConnected: true)),
      expect: <NetworkBloc>() => [
        isA<NetworkSuccess>(),
      ],
    );

    blocTest<NetworkBloc, NetworkState>(
      'Should initialize with no connection network',
      build: () => NetworkBloc(),
      act: (NetworkBloc bloc) => bloc.add(NetworkNotify(isConnected: false)),
      expect: <NetworkBloc>() => [
        isA<NetworkFailure>(),
      ],
    );
  });
}