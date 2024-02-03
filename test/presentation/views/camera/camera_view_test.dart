import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

//utils
import 'package:bexdeliveries/src/utils/constants/keys.dart';
//bloc
import 'package:bexdeliveries/src/presentation/blocs/camera/camera_bloc.dart';
//view
import 'package:bexdeliveries/src/presentation/views/user/camera/index.dart';
//mocks
import 'camera_view_test.mocks.dart';

@GenerateMocks([], customMocks: [MockSpec<CameraBloc>(onMissingStub: null)])
void main() {
  late CameraBloc cameraBloc;
  late Widget app;

  setUp(() {
    cameraBloc = MockCameraBloc();
    app = MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: cameraBloc,
          child: BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) => const CameraView(),
          ),
        ),
      ),
    );
    when(cameraBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    cameraBloc.close();
  });

  group('CameraScreen', () {
    testWidgets('Should show an empty container when state is CameraInitial',
        (WidgetTester tester) async {
      when(cameraBloc.state).thenAnswer((_) => CameraInitial());

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byKey(MyPhotosKeys.emptyContainerScreen), findsOneWidget);
    });

    testWidgets('Should show the camera preview when state is CameraReady',
        (WidgetTester tester) async {
      when(cameraBloc.state).thenAnswer((_) => CameraReady());
      when(cameraBloc.getController()).thenAnswer(
        (_) => CameraController(
            const CameraDescription(
                name: '',
                lensDirection: CameraLensDirection.external,
                sensorOrientation: 0),
            ResolutionPreset.high),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byKey(MyPhotosKeys.cameraPreviewScreen), findsOneWidget);
    });

    testWidgets('Should show the error message when state is CameraFailure',
        (WidgetTester tester) async {
      when(cameraBloc.state).thenAnswer((_) => const CameraFailure(
          error: "MediaRecorderCamera permission not granted"));

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byKey(MyPhotosKeys.errorScreen), findsOneWidget);
      expect(find.text("MediaRecorderCamera permission not granted"),
          findsOneWidget);
    });

    testWidgets(
        'Should show an empty container when state is CameraCaptureInProgress',
        (WidgetTester tester) async {
      when(cameraBloc.state).thenAnswer((_) => CameraCaptureInProgress());

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byKey(MyPhotosKeys.emptyContainerScreen), findsOneWidget);
    });
  });
}
