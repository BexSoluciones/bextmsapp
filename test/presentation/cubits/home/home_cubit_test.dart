import 'package:bexdeliveries/src/domain/models/user.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/annotations.dart';

//domain
import 'package:bexdeliveries/src/domain/models/work.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:bexdeliveries/src/domain/repositories/api_repository.dart';
//cubit
import 'package:bexdeliveries/src/presentation/cubits/home/home_cubit.dart';
//blocs
import 'package:bexdeliveries/src/presentation/blocs/gps/gps_bloc.dart';
import 'package:bexdeliveries/src/presentation/blocs/network/network_bloc.dart';
import 'package:bexdeliveries/src/presentation/blocs/processing_queue/processing_queue_bloc.dart';
import 'package:mockito/mockito.dart';
//mocks
import 'home_cubit_test.mocks.dart';
import '../../../firebase_mock.dart';
//services
import '../../../locator_mock.dart';
import '../../../locator_mock.mocks.dart';

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
  late NetworkBloc networkBloc;
  late MockLocalStorageService storageService;
  late MockNavigationService navigationService;
  late MockWorkmanagerService workmanagerService;

  final user = User();

  setUpAll(() async {
    await initializeTestDependencies();
    await Firebase.initializeApp();

    databaseRepository = MockDatabaseRepository();
    apiRepository = MockApiRepository();
    processingQueueBloc = MockProcessingQueueBloc();
    gpsBloc = MockGpsBloc();
    networkBloc = MockNetworkBloc();
    storageService = locator<MockLocalStorageService>();
    navigationService = locator<MockNavigationService>();
    workmanagerService = locator<MockWorkmanagerService>();

    // Default responses
    when(databaseRepository.getAllWorks())
        .thenAnswer((_) => Future.value(List<Work>.empty()));
    when(storageService.getObject(any)).thenAnswer((_) => {});
  });

  tearDownAll(() {
    unregisterDependencies();
  });

  group('HomeInitialized', () {
    blocTest<HomeCubit, HomeState>(
      'Should get all works',
      build: () => HomeCubit(
          databaseRepository,
          apiRepository,
          processingQueueBloc,
          gpsBloc,
          networkBloc,
          storageService,
          navigationService,
          workmanagerService),
      act: (HomeCubit bloc) => bloc.getAllWorks(),
      expect: () => [
        isA<HomeState>()
          ..having((p0) => p0.status, "status of cubit", HomeStatus.success)
          ..having((p1) => p1.works, "list of works of cubit", isEmpty)
          ..having((p2) => p2.user, "user of cubit", user)
          ..having((p3) => p3.error, "error of cubit", isNull)
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'Should sync works',
      build: () => HomeCubit(
          databaseRepository,
          apiRepository,
          processingQueueBloc,
          gpsBloc,
          networkBloc,
          storageService,
          navigationService,
          workmanagerService),
      act: (HomeCubit bloc) => bloc.sync(),
      expect: <HomeState>() => [isA<HomeState>()],
    );

    blocTest<HomeCubit, HomeState>(
      'Should logout',
      build: () => HomeCubit(
          databaseRepository,
          apiRepository,
          processingQueueBloc,
          gpsBloc,
          networkBloc,
          storageService,
          navigationService,
          workmanagerService),
      act: (HomeCubit bloc) => bloc.logout(),
      expect: <HomeState>() => [isA<HomeState>()],
    );
  });


}
