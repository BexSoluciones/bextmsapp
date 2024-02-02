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
import '../../firebase_mock.dart';
//services
import '../../locator_mock.dart';
import '../../services/storage_mock.dart';
// import 'package:bexdeliveries/src/services/storage.dart';
// import 'package:bexdeliveries/src/services/navigation.dart';
// import 'package:bexdeliveries/src/services/workmanager.dart';

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
  late LocalStorageService storageService;

  setUpAll(() async {
    await initializeTestDependencies();
    await Firebase.initializeApp();
    
    databaseRepository = MockDatabaseRepository();
    apiRepository = MockApiRepository();
    processingQueueBloc = MockProcessingQueueBloc();
    gpsBloc = MockGpsBloc();
    networkBloc = MockNetworkBloc();
    storageService = locator<LocalStorageService>();

    // Default responses
    when(databaseRepository.getAllWorks()).thenAnswer((_) => Future.value(List<Work>.empty()));
    // when(storageService.getObject(any)).thenAnswer((_) => anyNamed('user'));
    

  });

  group('HomeInitialized', () {
    blocTest<HomeCubit, HomeState>(
      'Should initialize the camera controller',
      build: () => HomeCubit(
          databaseRepository,
          apiRepository,
          processingQueueBloc,
          gpsBloc,
          networkBloc
      ),
      act: (HomeCubit bloc) => bloc.getAllWorks(),
      expect: () => [
        const HomeState(status: HomeStatus.success, works: [], user: null)
      ],
    );

    // blocTest<CameraBloc, CameraState>(
    //   'Should throw an error (permission not granted)',
    //   build: () {
    //     when(cameraController.initialize()).thenAnswer((_) => Future.error(
    //         CameraException("cameraPermission",
    //             "MediaRecorderCamera permission not granted")));
    //     return CameraBloc(
    //         cameraUtils: cameraUtils, databaseRepository: databaseRepository);
    //   },
    //   act: (CameraBloc bloc) => bloc.add(CameraInitialized()),
    //   expect: <CameraState>() => [
    //     const CameraFailure(error: "MediaRecorderCamera permission not granted")
    //   ],
    // );
    //
    // blocTest<CameraBloc, CameraState>(
    //   'Should throw an error (no camera on device)',
    //   build: () {
    //     when(cameraUtils.getCameraController(any, any)).thenAnswer(
    //             (_) => Future.error(Exception("Bad state: no element")));
    //     return CameraBloc(
    //         cameraUtils: cameraUtils, databaseRepository: databaseRepository);
    //   },
    //   act: (CameraBloc bloc) => bloc.add(CameraInitialized()),
    //   expect: <CameraState>() => [
    //     const CameraFailure(error: "Exception: Bad state: no element"),
    //   ],
    // );
  });


}