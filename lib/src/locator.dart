import 'package:bexdeliveries/src/services/remote_config.dart';
import 'package:get_it/get_it.dart';

//cache
import '../core/cache/cache_manager.dart';
import '../core/cache/storage/cache_storage.dart';

import 'data/datasources/local/app_database.dart';
import 'data/datasources/remote/api_service.dart';
import 'data/repositories/api_repository_impl.dart';
import 'data/repositories/database_repository_impl.dart';
import 'domain/repositories/api_repository.dart';
import 'domain/repositories/database_repository.dart';

//services
import 'services/storage.dart';
import 'services/navigation.dart';
import 'services/notifications.dart';
import 'services/analytics.dart';
import 'services/logger.dart';
import 'services/workmanager.dart';

final locator = GetIt.instance;

Future<void> initializeDependencies() async {

  locator.registerLazySingleton(() => FirebaseAnalyticsService());

  final storage = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(storage!);

  final navigation = NavigationService();
  locator.registerSingleton<NavigationService>(navigation);

  final notification = await NotificationService.getInstance();
  locator.registerSingleton<NotificationService>(notification!);

  final remoteConfig = await RemoteConfigService.getInstance();
  locator.registerSingleton<RemoteConfigService>(remoteConfig!);


  final workmanager = await WorkmanagerService.getInstance();
  locator.registerSingleton<WorkmanagerService>(workmanager!);

  final logger = LoggerService();
  locator.registerSingleton<LoggerService>(logger);


  final db = AppDatabase.instance;
  locator.registerSingleton<AppDatabase>(db);

  locator.registerSingleton<CacheManager>(CacheManager(CacheStorage()));

  locator.registerSingleton<ApiService>(
    ApiService(),
  );

  locator.registerSingleton<ApiRepository>(
    ApiRepositoryImpl(locator<ApiService>()),
  );

  locator.registerSingleton<DatabaseRepository>(
    DatabaseRepositoryImpl(locator<AppDatabase>()),
  );
}