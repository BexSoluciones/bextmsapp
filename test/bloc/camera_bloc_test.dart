import 'package:bloc_test/bloc_test.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:bexdeliveries/src/locator.dart';

//utils
import 'package:bexdeliveries/src/utils/resources/camera.dart';
//bloc
import 'package:bexdeliveries/src/presentation/blocs/camera/camera_bloc.dart';
import 'package:mockito/mockito.dart';

const String path = "path/to/directory";

class MockDatabaseRepository extends Mock implements DatabaseRepository {}

class MockCameraController extends Mock implements CameraController {}

class MockCameraUtils extends Mock implements CameraUtils {
  @override
  Future<String> getPath() => Future.value(path);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  late MockDatabaseRepository databaseRepository;
  late MockCameraController cameraController;
  late MockCameraUtils cameraUtils;

  setUp(() {
    databaseRepository = MockDatabaseRepository();
    cameraController = MockCameraController();
    cameraUtils = MockCameraUtils();

    // Default responses
    // when(cameraController.initialize()).thenAnswer((_) => Future.value());
    // when(cameraUtils.getCameraController(
    //         ResolutionPreset.high, CameraLensDirection.back))
    //     .thenAnswer((_) => Future.value(cameraController));
  });

  group('CameraInitialized', () {
    blocTest<CameraBloc, CameraState>(
      'Should initialize the camera controller',
      build: () => CameraBloc(
          cameraUtils: cameraUtils,
          databaseRepository: databaseRepository),
      act: (CameraBloc bloc) => bloc.add(CameraInitialized()),
      expect: <CameraState>() => [
        CameraReady(),
      ],
    );

    // blocTest<CameraBloc, CameraState>(
    //   'Should throw an error (permission not granted)',
    //   build: () {
    //     when(cameraController.initialize()).thenAnswer((_) => Future.error(
    //         CameraException("cameraPermission",
    //             "MediaRecorderCamera permission not granted")));
    //     return CameraBloc(
    //         cameraUtils: cameraUtils,
    //         databaseRepository: locator<DatabaseRepository>());
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
    //     when(cameraUtils.getCameraController(
    //             ResolutionPreset.high, CameraLensDirection.back))
    //         .thenAnswer(
    //             (_) => Future.error(Exception("Bad state: no element")));
    //     return CameraBloc(
    //         cameraUtils: cameraUtils,
    //         databaseRepository: locator<DatabaseRepository>());
    //   },
    //   act: (CameraBloc bloc) => bloc.add(CameraInitialized()),
    //   expect: <CameraState>() => [
    //     const CameraFailure(error: "Exception: Bad state: no element"),
    //   ],
    // );
  });
  //
  // group('CameraCaptured', () {
  //   // blocTest<CameraBloc, CameraState>(
  //   //   'Should capture a photo',
  //   //   build: () {
  //   //     when(cameraController.value).thenAnswer((_) => CameraValue());
  //   //     when(cameraController.takePicture())
  //   //         .thenAnswer((_) => Future.value());
  //   //     return CameraBloc(cameraUtils: cameraUtils, databaseRepository: locator<DatabaseRepository>());
  //   //   },
  //   //   act: (CameraBloc bloc) =>
  //   //   bloc..add(CameraInitialized())..add(CameraCaptured()),
  //   //   expect: <CameraState>() => [
  //   //     CameraReady(),
  //   //     CameraCaptureInProgress(),
  //   //     const CameraCaptureSuccess(path)
  //   //   ],
  //   // );
  //
  //   // blocTest<CameraBloc, CameraState>(
  //   //   'Should throw an error (problem with the camera)',
  //   //   build: () {
  //   //     when(cameraController.value)
  //   //         .thenAnswer((_) => CameraValue(isTakingPicture: false));
  //   //     when(cameraController.takePicture()).thenAnswer(
  //   //             (_) => Future.error(CameraException("error", "description")));
  //   //     return CameraBloc(cameraUtils: cameraUtils, databaseRepository: locator<DatabaseRepository>());
  //   //   },
  //   //   act: (CameraBloc bloc) =>
  //   //   bloc..add(CameraInitialized())..add(CameraCaptured()),
  //   //   expect: <CameraState>() => [
  //   //     CameraReady(),
  //   //     CameraCaptureInProgress(),
  //   //     CameraCaptureFailure(error: "description")
  //   //   ],
  //   // );
  //
  //   blocTest<CameraBloc, CameraState>(
  //     'Should pass nothing (camera is not ready)',
  //     build: () => CameraBloc(
  //         cameraUtils: cameraUtils,
  //         databaseRepository: locator<DatabaseRepository>()),
  //     act: (CameraBloc bloc) => bloc.add(CameraCaptured()),
  //     expect: <CameraState>() => [],
  //   );
  // });
  //
  // group('CameraStopped', () {
  //   blocTest<CameraBloc, CameraState>(
  //     'Should dispose the camera',
  //     build: () => CameraBloc(
  //         cameraUtils: cameraUtils,
  //         databaseRepository: locator<DatabaseRepository>()),
  //     act: (CameraBloc bloc) => bloc
  //       ..add(CameraInitialized())
  //       ..add(CameraStopped()),
  //     expect: <CameraState>() => [
  //       CameraReady(),
  //       CameraInitial(),
  //     ],
  //   );
  // });
}
