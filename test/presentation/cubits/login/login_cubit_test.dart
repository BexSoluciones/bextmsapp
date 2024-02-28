import 'dart:ui';
import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/annotations.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

//domain
import '../../../domain/repositories/api_repository.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
//cubit
import 'package:bexdeliveries/src/presentation/cubits/login/login_cubit.dart';
//blocs
import 'package:bexdeliveries/src/presentation/blocs/gps/gps_bloc.dart';
import 'package:bexdeliveries/src/presentation/blocs/network/network_bloc.dart';
import 'package:bexdeliveries/src/presentation/blocs/processing_queue/processing_queue_bloc.dart';
import 'package:mockito/mockito.dart';
//mocks
import '../../../domain/repositories/api_repository.mocks.dart';
import 'login_cubit_test.mocks.dart';
import '../../../firebase_mock.dart';
import '../../../locator_mock.dart';
import '../../../locator_mock.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<DatabaseRepository>(onMissingStub: null),
  MockSpec<ProcessingQueueBloc>(onMissingStub: null),
  MockSpec<GpsBloc>(onMissingStub: null),
  MockSpec<NetworkBloc>(onMissingStub: null),
])
void main() {
  setupFirebaseAuthMocks();

  late Dio dio;
  late DioAdapter dioAdapter;
  const loginUrl = 'https://pandapan.bexmovil.com/api/auth/login';

  late DatabaseRepository databaseRepository;
  late MockApiRepository apiRepository;
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

    dio = Dio(BaseOptions(baseUrl: 'https://demo.bexdeliveries.com/api'));
    dioAdapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    dio.httpClientAdapter = dioAdapter;

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
      'emits [LoginStatus.loading, LoginStatus.success]'
      'api login emit state for successful',
      setUp: () => dioAdapter.onPost(
        loginUrl,
        (request) => request.reply(200, apiRepository.fakeGoodLoginResponse),
        data: Matchers.any,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ),
      build: () {
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

  });
}
