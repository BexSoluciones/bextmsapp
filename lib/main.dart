import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:location_repository/location_repository.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path/path.dart' as p;

//plugins
import 'package:charger_status/charger_status.dart';
import 'package:permission_handler/permission_handler.dart';
//theme
import 'src/config/theme/app.dart';

//domain
import 'src/domain/repositories/api_repository.dart';
import 'src/domain/repositories/database_repository.dart';
import '../../src/domain/models/notification.dart';

//cubits
import 'src/presentation/blocs/theme/theme_bloc.dart';
import 'src/presentation/cubits/initial/initial_cubit.dart';
import 'src/presentation/cubits/permission/permission_cubit.dart';
import 'src/presentation/cubits/politics/politics_cubit.dart';
import 'src/presentation/cubits/login/login_cubit.dart';
import 'src/presentation/cubits/home/home_cubit.dart';
import 'src/presentation/cubits/work/work_cubit.dart';
import 'src/presentation/cubits/type/work_type_cubit.dart';
import 'src/presentation/cubits/confirm/confirm_cubit.dart';
import 'src/presentation/cubits/summary/summary_cubit.dart';
import 'src/presentation/cubits/georeference/georeference_cubit.dart';
import 'src/presentation/cubits/inventory/inventory_cubit.dart';
import 'src/presentation/cubits/reject/reject_cubit.dart';
import 'src/presentation/cubits/partial/partial_cubit.dart';
import 'src/presentation/cubits/respawn/respawn_cubit.dart';
import 'src/presentation/cubits/collection/collection_cubit.dart';
import 'src/presentation/cubits/database/database_cubit.dart';
import 'src/presentation/cubits/navigation/navigation_cubit.dart';
import 'src/presentation/cubits/general/general_cubit.dart';
import 'src/presentation/cubits/download/download_cubit.dart';
import 'src/presentation/cubits/query/query_cubit.dart';
import 'src/presentation/cubits/transaction/transaction_cubit.dart';
import 'src/presentation/cubits/notification/count/count_cubit.dart';
import 'src/presentation/cubits/notification/notification_cubit.dart';
import 'src/presentation/cubits/ordersummaryreasons/ordersummaryreasons_cubit.dart';

//blocs
import 'src/presentation/blocs/network/network_bloc.dart';
import 'src/presentation/blocs/processing_queue/processing_queue_bloc.dart';
import 'src/presentation/blocs/location/location_bloc.dart';
import 'src/presentation/blocs/photo/photo_bloc.dart';
import 'src/presentation/blocs/history_order/history_order_bloc.dart';
import 'src/presentation/blocs/issues/issues_bloc.dart';
import 'src/presentation/blocs/account/account_bloc.dart';
import 'src/presentation/blocs/gps/gps_bloc.dart';
import 'src/presentation/blocs/camera/camera_bloc.dart';

//database
import 'src/data/datasources/local/app_database.dart';

//providers
import 'src/presentation/providers/photo_provider.dart';

//utils
import 'src/utils/constants/strings.dart';
import 'src/utils/resources/camera.dart';

//service
import 'src/locator.dart';
import 'src/services/navigation.dart';
import 'src/services/storage.dart';
import 'src/services/analytics.dart';
import 'src/services/notifications.dart';
import 'src/services/remote_config.dart';
import 'src/services/logger.dart';

//router
import 'src/config/router/routes.dart';

//undefined
import 'src/presentation/views/global/undefined_view.dart';

//widget
import 'src/presentation/widgets/custom_error_widget.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NotificationService _notificationService = locator<NotificationService>();
final RemoteConfigService _remoteConfigService = locator<RemoteConfigService>();
final LoggerService _loggerService = locator<LoggerService>();

List<CameraDescription> cameras = [];

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final notificationDao = NotificationDao(AppDatabase.instance);
  final pushNotification = (PushNotification(
      id_from_server: message.data['notification_id'],
      title: message.notification?.title,
      body: message.notification?.body,
      with_click_action: message.notification?.android?.clickAction,
      date: message.data['date'],
      read_at: null));
  await notificationDao.insertNotification(pushNotification);
}

@pragma('vm:entry-point')
void callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  ChargerStatus.instance.listenToEvents().listen((event) {
    logDebug(headerMainLogger, 'onNewEvent: $event');
  });

  ChargerStatus.instance.startPowerChangesListener();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  await Firebase.initializeApp();
  await initializeDependencies();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final databaseCubit =
      DatabaseCubit(locator<ApiRepository>(), locator<DatabaseRepository>());
  await databaseCubit.getDatabase();

  ChargerStatus.instance.registerHeadlessDispatcher(callbackDispatcher);

  _loggerService.setLogLevel(LogLevel.debugFinest);

  logDebugFinest(headerMainLogger, 'Starting a expensive async operation...');

  try {
    await _notificationService.init();
    logDebugFine(headerMainLogger, 'Notification already done');
  } catch (error) {
    logErrorObject(
        headerMainLogger, error, 'Caught an error in the async operation!');
  }

  bool damagedDatabaseDeleted = false;

  await FlutterMapTileCaching.initialise(
    errorHandler: (error) => damagedDatabaseDeleted = error.wasFatal,
    debugMode: true,
  );

  _storageService.setBool('damaged_database_deleted', damagedDatabaseDeleted);

  await FMTC.instance.rootDirectory.migrator.fromV6(urlTemplates: []);

  if (_storageService.getBool('reset') ?? false) {
    await FMTC.instance.rootDirectory.manage.reset();
  }

  final File newAppVersionFile = File(
    p.join(
      // ignore: invalid_use_of_internal_member, invalid_use_of_protected_member
      FMTC.instance.rootDirectory.directory.absolute.path,
      'newAppVersion.${Platform.isWindows ? 'exe' : 'apk'}',
    ),
  );

  if (await newAppVersionFile.exists()) await newAppVersionFile.delete();

  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    FlutterError.dumpErrorToConsole(details);
    runApp(ErrorWidgetClass(details));
  };

  runApp(MyApp(databaseCubit: databaseCubit));
}

class ErrorWidgetClass extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  const ErrorWidgetClass(this.errorDetails, {super.key});
  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      errorMessage: errorDetails.exceptionAsString(),
    );
  }
}

class MyApp extends StatefulWidget {
  final DatabaseCubit databaseCubit;
  const MyApp({super.key, required this.databaseCubit});

  @override
  State<MyApp> createState() => _MyAppState(databaseCubit);
}

class _MyAppState extends State<MyApp> {
  final DatabaseCubit databaseCubit;

  _MyAppState(this.databaseCubit);
  Future<void> setupInteractedMessage(BuildContext context) async {
    initialize(context);
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
          'Message also contained a notification: ${initialMessage.notification!.body}');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message data 1 : ${message.data}');
        display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('On message app');
      debugPrint('Message data: ${message.data}');
      if (message.notification != null) {
        display(message);
      }
    });
  }

  Future<void> initialize(BuildContext context) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        "01",
        "Bex Deliveries",
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ));

      await FlutterLocalNotificationsPlugin().show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e, stackTrace) {
      debugPrint(e.toString());
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
  }

  Future<void> _fetchRemoteConfig() async {
    while (true) {
      try {
        //Firebase
        var codeTransporter =
            _remoteConfigService.getString('code_transporter');
        var forceProcessingQueue =
            _remoteConfigService.getBool('force_processing_queue');
        var enterprise = _remoteConfigService.getString('enterprise');
        var forceDatabase =
            _remoteConfigService.getBool('force_database_users');

        if (forceDatabase! &&
            codeTransporter == _storageService.getString('username') &&
            enterprise == _storageService.getString('company')) {
          if (context.mounted) databaseCubit.exportDatabase(context, false);
        }
        if (forceProcessingQueue! &&
            codeTransporter == _storageService.getString('username') &&
            enterprise == _storageService.getString('company')) {}
      } catch (e, stackTrace) {
        await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }

      await Future.delayed(
          Duration(minutes: _storageService.getInt('time_to_callback') ?? 10));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          RepositoryProvider(create: (context) => LocationRepository()),
          BlocProvider(
            create: (context) => PhotosBloc(
                photoProvider: PhotoProvider(
                    databaseRepository: locator<DatabaseRepository>()))
              ..add(PhotosLoaded()),
          ),
          BlocProvider(
            create: (_) => NetworkBloc()..add(NetworkObserve()),
          ),
          BlocProvider(
            create: (context) => ProcessingQueueBloc(
                locator<DatabaseRepository>(),
                locator<ApiRepository>(),
                BlocProvider.of<NetworkBloc>(context))
              ..add(ProcessingQueueObserve()),
          ),
          BlocProvider(
              create: (context) => LocationBloc(
                  locationRepository: context.read<LocationRepository>(),
                  databaseRepository: locator<DatabaseRepository>())
                ..add(GetLocation())),
          BlocProvider(
            create: (context) => ThemeBloc(),
          ),
          BlocProvider(create: (_) => GpsBloc()),
          BlocProvider(
              create: (context) => InitialCubit(locator<ApiRepository>())),
          BlocProvider(create: (context) => PermissionCubit()),
          BlocProvider(create: (context) => PoliticsCubit()),
          BlocProvider(
              create: (context) => LoginCubit(
                  locator<ApiRepository>(),
                  locator<DatabaseRepository>(),
                  locator<LocationRepository>(),
                  BlocProvider.of<ProcessingQueueBloc>(context),
                  BlocProvider.of<GpsBloc>(context))),
          BlocProvider(
              create: (context) => HomeCubit(
                  locator<DatabaseRepository>(),
                  locator<ApiRepository>(),
                  BlocProvider.of<ProcessingQueueBloc>(context),
                  BlocProvider.of<GpsBloc>(context))),
          BlocProvider(
            create: (context) => HistoryOrderBloc(locator<DatabaseRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context)),
          ),
          BlocProvider(
            create: (context) => WorkCubit(locator<DatabaseRepository>()),
          ),
          BlocProvider(
            create: (context) => ConfirmCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context),
                BlocProvider.of<GpsBloc>(context)),
          ),
          BlocProvider(
            create: (context) => SummaryCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context),
                BlocProvider.of<GpsBloc>(context)),
          ),
          BlocProvider(
            create: (context) => GeoReferenceCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context),
                BlocProvider.of<GpsBloc>(context)),
          ),
          BlocProvider(
            create: (context) => InventoryCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context)),
          ),
          BlocProvider(
            create: (context) => PartialCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context)),
          ),
          BlocProvider(
            create: (context) => RejectCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context)),
          ),
          BlocProvider(
            create: (context) => RespawnCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context)),
          ),
          BlocProvider(
            create: (context) => CollectionCubit(
                locator<DatabaseRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context),
                BlocProvider.of<GpsBloc>(context)),
          ),
          BlocProvider(
            create: (context) => NavigationCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<GpsBloc>(context)),
          ),
          BlocProvider(
            create: (context) => DatabaseCubit(
                locator<ApiRepository>(), locator<DatabaseRepository>()),
          ),
          BlocProvider(
              create: (context) => TransactionCubit(
                  locator<DatabaseRepository>(), locator<ApiRepository>())),
          BlocProvider(
            create: (context) => GeneralCubit(),
          ),
          BlocProvider(
            create: (context) => DownloadCubit(),
          ),
          BlocProvider(
            create: (context) => QueryCubit(locator<DatabaseRepository>()),
          ),
          BlocProvider(
            create: (context) => IssuesBloc(
                locator<DatabaseRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context),
                BlocProvider.of<GpsBloc>(context)),
          ),
          BlocProvider(
            create: (_) => CameraBloc(
                cameraUtils: CameraUtils(),
                databaseRepository: locator<DatabaseRepository>())
              ..add(CameraInitialized()),
          ),
          BlocProvider(
            create: (context) => AccountBloc(locator<DatabaseRepository>()),
          ),
          BlocProvider(
            create: (context) => WorkTypeCubit(locator<DatabaseRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                OrdersummaryreasonsCubit(locator<DatabaseRepository>()),
          ),
          BlocProvider(
              create: (context) =>
                  NotificationCubit(locator<DatabaseRepository>())),
          BlocProvider(
              create: (context) => CountCubit(locator<DatabaseRepository>())),
        ],
        child: BlocProvider(
            create: (context) => ThemeBloc(),
            child:
                BlocBuilder<ThemeBloc, ThemeState>(builder: (context, state) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: OverlaySupport(child: DynamicColorBuilder(builder:
                    (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                  ColorScheme lightScheme;
                  ColorScheme darkScheme;

                  lightScheme = lightColorScheme;
                  darkScheme = darkColorScheme;

                  return StreamBuilder(
                    initialData: false,
                    stream: context.read<ProcessingQueueBloc>().resolve,
                    builder: (context, snapshot) => MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: appTitle,
                      theme: ThemeData(
                        useMaterial3: true,
                        colorScheme:
                            state.isDarkTheme ? lightScheme : darkScheme,
                        // extensions: [lightCustomColors],
                      ),
                      darkTheme: ThemeData(
                        useMaterial3: true,
                        colorScheme:
                            state.isDarkTheme ? lightScheme : darkScheme,
                        // extensions: [darkCustomColors],
                      ),
                      themeMode: ThemeMode.system,
                      navigatorKey: locator<NavigationService>().navigatorKey,
                      navigatorObservers: [
                        locator<FirebaseAnalyticsService>()
                            .appAnalyticsObserver(),
                      ],
                      onUnknownRoute: (RouteSettings settings) =>
                          MaterialPageRoute(
                              builder: (BuildContext context) => UndefinedView(
                                    name: settings.name,
                                  )),
                      initialRoute: '/splash',
                      onGenerateRoute: Routes.onGenerateRoutes,
                    ),
                  );
                })),
              );
            })));
  }

  @override
  void initState() {
    setupInteractedMessage(context);
    _fetchRemoteConfig();
    widget.databaseCubit.getDatabase();
    super.initState();
  }
}
