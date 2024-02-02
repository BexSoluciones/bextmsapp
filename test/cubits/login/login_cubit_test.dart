import 'dart:ui';

import 'package:bexdeliveries/src/domain/models/requests/login_request.dart';
import 'package:bexdeliveries/src/domain/models/user.dart';
import 'package:bexdeliveries/src/services/geolocator.dart';
import 'package:bexdeliveries/src/utils/resources/data_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/annotations.dart';

//domain
import 'package:bexdeliveries/src/domain/models/work.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:bexdeliveries/src/domain/repositories/api_repository.dart';
//cubit
import 'package:bexdeliveries/src/presentation/cubits/login/login_cubit.dart';
//blocs
import 'package:bexdeliveries/src/presentation/blocs/gps/gps_bloc.dart';
import 'package:bexdeliveries/src/presentation/blocs/network/network_bloc.dart';
import 'package:bexdeliveries/src/presentation/blocs/processing_queue/processing_queue_bloc.dart';
import 'package:mockito/mockito.dart';
//mocks
import 'login_cubit_test.mocks.dart';
import '../../firebase_mock.dart';
//services
import '../../locator_mock.dart';
import '../../locator_mock.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<DatabaseRepository>(onMissingStub: null),
  MockSpec<ApiRepository>(onMissingStub: null),
  MockSpec<ProcessingQueueBloc>(onMissingStub: null),
  MockSpec<GpsBloc>(onMissingStub: null),
  MockSpec<NetworkBloc>(onMissingStub: null),
])
void main() {
  setupFirebaseAuthMocks();

  late DatabaseRepository databaseRepository;
  late ApiRepository apiRepository;
  late ProcessingQueueBloc processingQueueBloc;
  late GpsBloc gpsBloc;
  late MockLocalStorageService storageService;
  late MockNavigationService navigationService;
  late MockGeolocatorService geolocationService;

  final username = TextEditingController(text: 'username');
  final password = TextEditingController(text: 'password');

  setUpAll(() async {
    DartPluginRegistrant.ensureInitialized();
    await initializeTestDependencies();
    await Firebase.initializeApp();

    databaseRepository = MockDatabaseRepository();
    apiRepository = MockApiRepository();
    processingQueueBloc = MockProcessingQueueBloc();
    gpsBloc = MockGpsBloc();
    storageService = locator<MockLocalStorageService>();
    navigationService = locator<MockNavigationService>();
    geolocationService = locator<MockGeolocatorService>();

    // Default responses
    when(storageService.getObject(any)).thenAnswer((_) => {});
    when(storageService.setObject(any, any)).thenAnswer((_) => Future.value());
    when(storageService.setString(any, any)).thenAnswer((_) => Future.value());
    when(storageService.setInt(any, any)).thenAnswer((_) => Future.value());

    when(geolocationService.acquireCurrentLocationGeo())
        .thenAnswer((_) => Future.value());
  });

  tearDownAll(() {
    unregisterDependencies();
  });

  group('LoginSuccess', () {
    blocTest<LoginCubit, LoginState>(
      'Should on press login',
      build: () {
        when(apiRepository.login(
                request: LoginRequest(username.text, password.text)))
            .thenAnswer((_) => Future.value());

        return LoginCubit(
            databaseRepository,
            apiRepository,
            processingQueueBloc,
            gpsBloc,
            storageService,
            navigationService,
            geolocationService);
      },
      act: (LoginCubit bloc) => bloc.onPressedLogin(username, password, true),
      expect: () => [const LoginLoading(), const LoginSuccess()],
    );

    // blocTest<LoginCubit, LoginState>(
    //   'Should sync works',
    //   build: () => LoginCubit(
    //       databaseRepository,
    //       apiRepository,
    //       processingQueueBloc,
    //       gpsBloc,
    //       networkBloc,
    //       storageService,
    //       navigationService,
    //       workmanagerService),
    //   act: (LoginCubit bloc) => bloc.sync(),
    //   expect: <LoginState>() => [isA<LoginState>()],
    // );
    //
    // blocTest<LoginCubit, LoginState>(
    //   'Should logout',
    //   build: () => LoginCubit(
    //       databaseRepository,
    //       apiRepository,
    //       processingQueueBloc,
    //       gpsBloc,
    //       networkBloc,
    //       storageService,
    //       navigationService,
    //       workmanagerService),
    //   act: (LoginCubit bloc) => bloc.logout(),
    //   expect: <LoginState>() => [isA<LoginState>()],
    // );
  });
}
