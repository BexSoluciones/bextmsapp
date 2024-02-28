// import 'package:bloc_test/bloc_test.dart';
// import 'package:camera/camera.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import '../../firebase_mock.dart';
//
// //mocks
// import 'camera_bloc_test.mocks.dart';
//
// //domain
// import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
//
// //utils
// import 'package:bexdeliveries/src/utils/resources/camera.dart';
// //bloc
// import 'package:bexdeliveries/src/presentation/blocs/camera/camera_bloc.dart';
// import 'package:mockito/mockito.dart';
//
// const String path = "path/to/directory";
//
// @GenerateMocks([], customMocks: [
//   MockSpec<DatabaseRepository>(onMissingStub: null),
//   MockSpec<CameraController>(onMissingStub: null),
//   MockSpec<CameraUtils>(onMissingStub: null),
//   MockSpec<CameraValue>(onMissingStub: null),
// ])
// void main() async {
//   setupFirebaseAuthMocks();
//
//   late MockDatabaseRepository databaseRepository;
//   late MockCameraController cameraController;
//   late MockCameraUtils cameraUtils;
//   late MockCameraValue cameraValue;
//
//   setUpAll(() async {
//     await Firebase.initializeApp();
//
//     databaseRepository = MockDatabaseRepository();
//     cameraController = MockCameraController();
//     cameraUtils = MockCameraUtils();
//     cameraValue = MockCameraValue();
//
//     // Default responses
//     when(cameraController.initialize()).thenAnswer((_) => Future.value());
//     when(cameraUtils.getCameraController(any, any))
//         .thenAnswer((_) => Future.value(cameraController));
//   });
//
//   group('CameraInitialized', () {
//     blocTest<CameraBloc, CameraState>(
//       'Should initialize the camera controller',
//       build: () => CameraBloc(
//           cameraUtils: cameraUtils, databaseRepository: databaseRepository),
//       act: (CameraBloc bloc) => bloc.add(CameraInitialized()),
//       expect: <CameraState>() => [
//         CameraReady(),
//       ],
//     );
//
//     blocTest<CameraBloc, CameraState>(
//       'Should throw an error (permission not granted)',
//       build: () {
//         when(cameraController.initialize()).thenAnswer((_) => Future.error(
//             CameraException("cameraPermission",
//                 "MediaRecorderCamera permission not granted")));
//         return CameraBloc(
//             cameraUtils: cameraUtils, databaseRepository: databaseRepository);
//       },
//       act: (CameraBloc bloc) => bloc.add(CameraInitialized()),
//       expect: <CameraState>() => [
//         const CameraFailure(error: "MediaRecorderCamera permission not granted")
//       ],
//     );
//
//     blocTest<CameraBloc, CameraState>(
//       'Should throw an error (no camera on device)',
//       build: () {
//         when(cameraUtils.getCameraController(any, any)).thenAnswer(
//                 (_) => Future.error(Exception("Bad state: no element")));
//         return CameraBloc(
//             cameraUtils: cameraUtils, databaseRepository: databaseRepository);
//       },
//       act: (CameraBloc bloc) => bloc.add(CameraInitialized()),
//       expect: <CameraState>() => [
//         const CameraFailure(error: "Exception: Bad state: no element"),
//       ],
//     );
//   });
//
//   group('CameraCaptured', () {
//     //TODO: [Heider Zapa review]
//     // blocTest<CameraBloc, CameraState>(
//     //   'Should capture a photo',
//     //   build: () {
//     //     when(cameraController.value).thenAnswer((_) => cameraValue);
//     //     when(cameraController.takePicture()).thenAnswer((_) => Future.value());
//     //     return CameraBloc(
//     //         cameraUtils: cameraUtils, databaseRepository: databaseRepository);
//     //   },
//     //   act: (CameraBloc bloc) => bloc
//     //     ..add(CameraInitialized())
//     //     ..add(CameraCaptured()),
//     //   expect: <CameraState>() => [
//     //     CameraReady(),
//     //     CameraCaptureInProgress(),
//     //     const CameraCaptureSuccess(path)
//     //   ],
//     // );
//     //
//     // blocTest<CameraBloc, CameraState>(
//     //   'Should throw an error (problem with the camera)',
//     //   build: () {
//     //     when(cameraController.value)
//     //         .thenAnswer((_) => cameraValue);
//     //     when(cameraController.takePicture()).thenAnswer(
//     //         (_) => Future.error(CameraException("error", "description")));
//     //     return CameraBloc(
//     //         cameraUtils: cameraUtils, databaseRepository: databaseRepository);
//     //   },
//     //   act: (CameraBloc bloc) => bloc
//     //     ..add(CameraInitialized())
//     //     ..add(CameraCaptured()),
//     //   expect: <CameraState>() => [
//     //     CameraReady(),
//     //     CameraCaptureInProgress(),
//     //     CameraCaptureFailure(error: "description")
//     //   ],
//     // );
//
//     blocTest<CameraBloc, CameraState>(
//       'Should pass nothing (camera is not ready)',
//       build: () => CameraBloc(
//           cameraUtils: cameraUtils, databaseRepository: databaseRepository),
//       act: (CameraBloc bloc) => bloc.add(CameraCaptured()),
//       expect: <CameraState>() => [
//         const CameraFailure(error: 'Camera is not ready')
//       ],
//     );
//   });
//
//   group('CameraStopped', () {
//     blocTest<CameraBloc, CameraState>(
//       'Should dispose the camera',
//       build: () => CameraBloc(
//           cameraUtils: cameraUtils, databaseRepository: databaseRepository),
//       act: (CameraBloc bloc) => bloc
//         ..add(CameraInitialized())
//         ..add(CameraStopped()),
//       expect: <CameraState>() => [
//         //TODO: [Heider Zapa] review
//         const CameraFailure(error: 'Exception: Bad state: no element'),
//         CameraInitial(),
//       ],
//     );
//   });
// }
