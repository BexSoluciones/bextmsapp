import 'package:bexdeliveries/src/presentation/cubits/database/database_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bexdeliveries/main.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseCubit extends Mock implements DatabaseCubit {}

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //
  //   final mockDatabaseCubit = MockDatabaseCubit();
  //   await tester.pumpWidget(MyApp(databaseCubit: mockDatabaseCubit));
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
}
