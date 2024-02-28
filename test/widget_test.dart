import 'package:bexdeliveries/src/presentation/cubits/database/database_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bexdeliveries/main.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseCubit extends Mock implements DatabaseCubit {}

void main() {
  group('App name - home', () {
    // FlutterDriver driver;
    //
    // setUpAll(() async {
    //   driver = await FlutterDriver.connect();
    // });
    //
    // tearDownAll(() async {
    //   if (driver != null) {
    //     driver.close();
    //   }
    // });

    // test('list has row items', () async {
    //   final timeline = await driver.traceAction(() async {
    //     // wait for list items
    //     await driver.waitFor(find.byValueKey('placesList'));
    //
    //     // get the first row in the list
    //     final firstRow = find.descendant(
    //         of: find.byValueKey('placesList'),
    //         matching: find.byType('PlaceRow'),
    //         firstMatchOnly: true);
    //
    //     // tap on the first row
    //     await driver.tap(firstRow);
    //
    //     // wait for place details
    //     await driver.waitFor(find.byValueKey("placeDetails"));
    //
    //     // go back to lists
    //     await driver.tap(find.byTooltip('Back'));
    //   });
    //
    //   // write summary to a file
    //   final summary = new TimelineSummary.summarize(timeline);
    //   await summary.writeSummaryToFile('ui_timeline', pretty: true);
    //   await summary.writeTimelineToFile('ui_timeline', pretty: true);
    // });
  });
}
