import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
//utils
import 'package:bexdeliveries/src/utils/constants/keys.dart';
//domain
import 'package:bexdeliveries/src/domain/models/photo.dart';
//bloc
import 'package:bexdeliveries/src/presentation/blocs/photo/photo_bloc.dart';
//view
import 'package:bexdeliveries/src/presentation/views/user/photos/index.dart';
//mock
import 'photo_view_test.mocks.dart';

@GenerateMocks([], customMocks: [MockSpec<PhotosBloc>(onMissingStub: null)])
void main() {
  late PhotosBloc photosBloc;

  final photos = [
    Photo(id: 1, name: "cat", path: "path/to/dir/cat"),
    Photo(id: 2, name: "tv", path: "path/to/dir/tv")
  ];

  late MaterialApp app;

  setUp(() {
    photosBloc = MockPhotosBloc();
    app = MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: photosBloc,
          child: BlocBuilder<PhotosBloc, PhotosState>(
            builder: (context, state) => const PhotoView(),
          ),
        ),
      ),
    );
    when(photosBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    photosBloc.close();
  });

  group('HomeScreen', () {
    testWidgets('Should show an empty container when state is PhotosInitial',
            (WidgetTester tester) async {
          when(photosBloc.state).thenAnswer((_) => PhotosInitial());

          await tester.pumpWidget(app);
          await tester.pumpAndSettle();

          expect(find.byKey(MyPhotosKeys.emptyContainerScreen), findsOneWidget);
        });

    testWidgets('Should show the loader when state is PhotosLoadInProgress',
            (WidgetTester tester) async {
          when(photosBloc.state).thenAnswer((_) => PhotosLoadInProgress());

          await tester.pumpWidget(app);
          await tester.pump(const Duration(seconds: 1));

          expect(find.byKey(MyPhotosKeys.loadingScreen), findsOneWidget);
        });

    testWidgets('Should show the grid when state is PhotosLoadSuccess',
            (WidgetTester tester) async {
          when(photosBloc.state).thenAnswer((_) => const PhotosLoadSuccess(photos: []));

          await tester.pumpWidget(app);
          await tester.pumpAndSettle();

          expect(find.byKey(MyPhotosKeys.photosGridScreen), findsOneWidget);
        });

    testWidgets(
        'Should show 2 photos when state is PhotosLoadSuccess with 2 photos loaded',
            (WidgetTester tester) async {
          when(photosBloc.state)
              .thenAnswer((_) => PhotosLoadSuccess(photos: photos));

          await tester.pumpWidget(app);
          await tester.pumpAndSettle();

          expect(find.byKey(MyPhotosKeys.photoCard), findsNWidgets(2));
        });

    testWidgets('Should show the error message when state is PhotosLoadFailure',
            (WidgetTester tester) async {
          when(photosBloc.state)
              .thenAnswer((_) => const PhotosLoadFailure(error: "Error loading photos"));

          await tester.pumpWidget(app);
          await tester.pumpAndSettle();

          expect(find.byKey(MyPhotosKeys.errorScreen), findsOneWidget);
          expect(find.text("Error loading photos"), findsOneWidget);
        });
  });
}