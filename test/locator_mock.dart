import 'package:get_it/get_it.dart';

//services
import './services/storage_mock.dart';
// import 'services/navigation.dart';
// import 'services/notifications.dart';
// import 'services/analytics.dart';
// import 'services/logger.dart';
// import 'services/workmanager.dart';

final locator = GetIt.instance;

Future<void> initializeTestDependencies() async {
  final storage = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(storage!);

  // final navigation = NavigationService();
  // locator.registerSingleton<NavigationService>(navigation);
  //
  //
  // final workmanager = await WorkmanagerService.getInstance();
  // locator.registerSingleton<WorkmanagerService>(workmanager!);
  //
  // final logger = LoggerService();
  // locator.registerSingleton<LoggerService>(logger);

}

Future<void> unregisterDependencies() async {
  final storage = await LocalStorageService.getInstance();
  locator.unregister<LocalStorageService>(instance: storage!);
}