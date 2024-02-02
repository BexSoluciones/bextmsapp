import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';

//services
import 'package:bexdeliveries/src/services/storage.dart';
import 'package:bexdeliveries/src/services/geolocator.dart';
import 'package:bexdeliveries/src/services/navigation.dart';
import 'package:bexdeliveries/src/services/workmanager.dart';

import 'locator_mock.mocks.dart';

final locator = GetIt.instance;

@GenerateMocks([], customMocks: [
  MockSpec<LocalStorageService>(onMissingStub: null),
  MockSpec<NavigationService>(onMissingStub: null),
  MockSpec<WorkmanagerService>(onMissingStub: null),
  MockSpec<GeolocatorService>(onMissingStub: null),
])
Future<void> initializeTestDependencies() async {
  final storage = MockLocalStorageService();
  locator.registerSingleton<MockLocalStorageService>(storage);

  final navigation = MockNavigationService();
  locator.registerSingleton<MockNavigationService>(navigation);

  final workmanager = MockWorkmanagerService();
  locator.registerSingleton<MockWorkmanagerService>(workmanager);

  final geolocator = MockGeolocatorService();
  locator.registerSingleton<MockGeolocatorService>(geolocator);
}

Future<void> unregisterDependencies() async {
  final storage = MockLocalStorageService();
  locator.unregister<LocalStorageService>(instance: storage);

  final navigation = MockNavigationService();
  locator.unregister<MockNavigationService>(instance: navigation);

  final workmanager = MockWorkmanagerService();
  locator.unregister<MockWorkmanagerService>(instance: workmanager);

  final geolocator = MockGeolocatorService();
  locator.unregister<MockGeolocatorService>(instance: geolocator);
}