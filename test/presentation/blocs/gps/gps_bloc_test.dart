import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:bexdeliveries/src/presentation/blocs/gps/gps_bloc.dart';
import 'package:bexdeliveries/src/services/navigation.dart';
import 'package:bexdeliveries/src/services/storage.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/mockito.dart';


class MockNavigationService extends Mock implements NavigationService {}
class MockLocalStorageService extends Mock implements LocalStorageService {}
class MockDatabaseRepository extends Mock implements DatabaseRepository {}


void main()async {
  late GpsBloc gpsBloc;
  late MockNavigationService mockNavigationService;
  late MockLocalStorageService mockLocalStorageService;
  late MockDatabaseRepository mockDatabaseRepository;
  WidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    mockNavigationService = MockNavigationService();
    mockLocalStorageService = MockLocalStorageService();
    mockDatabaseRepository = MockDatabaseRepository();
    gpsBloc = GpsBloc(
      navigationService: mockNavigationService,
      storageService: mockLocalStorageService,
      databaseRepository: mockDatabaseRepository,
    );
  });

  tearDown(() {
    gpsBloc.close();
  });

  group('GpsBloc', () {
    test('initial state is gps initial with no permissions', () {
      expect(
        gpsBloc.state,
        const GpsInitial(isGpsEnabled: false, isGpsPermissionGranted: false),
      );
    });

    test('GpsPermissionGranted event', () {
      const initialState = GpsInitial(isGpsEnabled: false, isGpsPermissionGranted: false);
      const expectedState = GpsPermissionGranted(isGpsPermissionGranted: true);
      gpsBloc.stream.listen((state) {
        expect(state, initialState);
        gpsBloc.add(const GpsPermissionGranted(isGpsPermissionGranted: true));
        gpsBloc.stream.listen((state) {
          expect(state, expectedState);
        });
      });
    });

    group('GpsGetCurrentPosition', () {
      blocTest<GpsBloc, GpsState>(
        'emits [GpsEnabled] when current position is obtained',
        build: () => gpsBloc,
        act: (bloc) => bloc.add(OnNewUserLocationEvent(
          Position(
              latitude: 4.6024161,
              longitude: -74.1650292,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0),
          LatLng(4.6024161, -74.1650292),
        )),
        expect: () => [isA<GpsState>().having((state) => state.isGpsEnabled, 'isGpsEnabled', true)],
      );
    });

    test('GpsStartFollowingUser', () {
      const initialState = GpsInitial(isGpsEnabled: false, isGpsPermissionGranted: false);
      const expectedState = GpsEnabled(isGpsEnabled: true);

      gpsBloc.stream.listen((state) {
        expect(state, initialState);

        gpsBloc.add(OnStartFollowingUser());

        gpsBloc.stream.listen((state) {
          expect(state, expectedState);
        });
      });
    });


    test('GpsStopFollowingUser', () {
      const initialState = GpsInitial(isGpsEnabled: true, isGpsPermissionGranted: false);
      const expectedState = GpsEnabled(isGpsEnabled: false);

      gpsBloc.stream.listen((state) {
        expect(state, initialState);

        gpsBloc.add(OnStopFollowingUser());

        gpsBloc.stream.listen((state) {
          expect(state, expectedState);
          expect(state.isGpsPermissionGranted, initialState.isGpsPermissionGranted);
          expect(state.followingUser, initialState.followingUser);
          expect(state.lastKnownLocation, initialState.lastKnownLocation);
        });
      });
    });

    test('GpsPermissionGranted event', () {
      const initialState = GpsInitial(isGpsEnabled: false, isGpsPermissionGranted: false);
      const expectedState = GpsPermissionGranted(isGpsPermissionGranted: true);

      gpsBloc.stream.listen((state) {
        expect(state, initialState);

        gpsBloc.add(const GpsPermissionGranted(isGpsPermissionGranted: true));
        gpsBloc.stream.listen((state) {
          expect(state, expectedState);
        });
      });
    });

    test('GpsEnabled event', () {
      const initialState = GpsInitial(isGpsEnabled: false, isGpsPermissionGranted: false);
      const expectedState = GpsEnabled(isGpsEnabled: true);

      gpsBloc.stream.listen((state) {
        expect(state, initialState);

        gpsBloc.add(const GpsEnabled(isGpsEnabled: true));
        gpsBloc.stream.listen((state) {
          expect(state, expectedState);
        });
      });
    });



    test('OnNewUserLocation event', () {
      const initialState = GpsInitial(isGpsEnabled: false, isGpsPermissionGranted: false);
      final newLocation = LatLng(10.0, 20.0);
      final newPosition = Position(
          latitude: 10.0,
          longitude: 20.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0);
      final expectedState = GpsState(
        isGpsEnabled: true,
        isGpsPermissionGranted: false,
        followingUser: false,
        lastKnownLocation: newLocation,
      );

      gpsBloc.stream.listen((state) {
        expect(state, initialState);

        gpsBloc.add(OnNewUserLocationEvent(newPosition, newLocation));
        gpsBloc.stream.listen((state) {
          expect(state, expectedState);
        });
      });
    });

    test('Error handling event', () {
      const initialState = GpsInitial(isGpsEnabled: false, isGpsPermissionGranted: false);
      const expectedState = GpsFailed(error: "Some error message", isGpsEnabled: false, isGpsPermissionGranted: false);

      gpsBloc.stream.listen((state) {
        expect(state, initialState);

        gpsBloc.add(const ShowErrorDialog());
        gpsBloc.stream.listen((state) {
          expect(state, expectedState);
        });
      });
    });
  });

}







