import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../firebase_mock.dart';
//domain
import 'package:bexdeliveries/src/presentation/blocs/gps/gps_bloc.dart';
//services
import '../../../locator_mock.dart';
import '../../../locator_mock.mocks.dart';

void main() {
  setupFirebaseAuthMocks();

  late MockDatabaseRepository databaseRepository;

  setUpAll(() async {
    await Firebase.initializeApp();
    databaseRepository = MockDatabaseRepository();
  });

  test('initial state is get user loading', () {
    expect(GpsBloc(databaseRepository: databaseRepository,
        navigationService: locator<MockNavigationService>(),
        storageService: locator<MockLocalStorageService>()).state,
        GpsInitial()
    );
  });

  group('GpsPermissions', () {
    // blocTest<GpsBloc, GpsState>(
    //   'Should initialize the camera controller',
    //   build: () => GpsBloc(
    //       databaseRepository: databaseRepository,
    //       navigationService: locator<MockNavigationService>(),
    //       storageService: locator<MockLocalStorageService>()),
    //   act: (GpsBloc bloc) => bloc.add(const GpsAndPermissionEvent(
    //       isGpsEnabled: false, isGpsPermissionGranted: false)),
    //   expect: <GpsState>() => [
    //     isA<>(),
    //     isA<>(),
    //   ],
    // );
  });

  group('GpsGetCurrentPosition',  () {

  });

  group('GpsStartFollowingUser',  () {

  });

  group('GpsStopFollowingUser',  () {

  });
}
