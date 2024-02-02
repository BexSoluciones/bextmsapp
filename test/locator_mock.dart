import 'package:bexdeliveries/src/services/navigation.dart';
import 'package:bexdeliveries/src/services/workmanager.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';

//services
import 'package:bexdeliveries/src/services/storage.dart';

import 'locator_mock.mocks.dart';
// import 'services/navigation.dart';
// import 'services/notifications.dart';
// import 'services/analytics.dart';
// import 'services/logger.dart';
// import 'services/workmanager.dart';

final locator = GetIt.instance;

@GenerateMocks([], customMocks: [
  MockSpec<LocalStorageService>(onMissingStub: null),
  MockSpec<NavigationService>(onMissingStub: null),
  MockSpec<WorkmanagerService>(onMissingStub: null),
])
Future<void> initializeTestDependencies() async {
  final storage = MockLocalStorageService();
  locator.registerSingleton<MockLocalStorageService>(storage);

  final navigation = MockNavigationService();
  locator.registerSingleton<MockNavigationService>(navigation);

  final workmanager = MockWorkmanagerService();
  locator.registerSingleton<MockWorkmanagerService>(workmanager);
}

Future<void> unregisterDependencies() async {
  final storage = MockLocalStorageService();
  locator.unregister<LocalStorageService>(instance: storage);

  final navigation = MockNavigationService();
  locator.registerSingleton<MockNavigationService>(navigation);

  final workmanager = MockWorkmanagerService();
  locator.registerSingleton<MockWorkmanagerService>(workmanager);
}