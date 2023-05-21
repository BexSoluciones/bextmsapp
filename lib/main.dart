import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:location/location.dart';
import 'package:location_repository/location_repository.dart';
import 'package:path/path.dart' as p;

//plugins
import 'plugins/charge_status.dart';
//theme
import 'src/config/theme/index.dart';

//domain
import 'src/domain/repositories/api_repository.dart';
import 'src/domain/repositories/database_repository.dart';

//cubits
import 'src/presentation/blocs/theme/theme_bloc.dart';
import 'src/presentation/cubits/initial/initial_cubit.dart';
import 'src/presentation/cubits/permission/permission_cubit.dart';
import 'src/presentation/cubits/politics/politics_cubit.dart';
import 'src/presentation/cubits/login/login_cubit.dart';
import 'src/presentation/cubits/home/home_cubit.dart';
import 'src/presentation/cubits/work/work_cubit.dart';
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

//blocs
import 'src/presentation/blocs/network/network_bloc.dart';
import 'src/presentation/blocs/processing_queue/processing_queue_bloc.dart';
import 'src/presentation/blocs/location/location_bloc.dart';
import 'src/presentation/blocs/photo/photo_bloc.dart';

//providers
import 'src/presentation/providers/photo_provider.dart';

//utils
import 'src/utils/constants/strings.dart';

//service
import 'src/locator.dart';
import 'src/services/navigation.dart';
import 'src/services/storage.dart';
import 'src/services/location.dart';
import 'src/services/timer.dart';

//router
import 'src/config/router/index.dart' as router;

//undefined
import 'src/presentation/views/global/undefined_view.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final LocationService _locationService = locator<LocationService>();
final TimerService _timerService = locator<TimerService>();

List<CameraDescription> cameras = [];

@pragma('vm:entry-point')
void callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  ChargerStatus.instance.listenToEvents().listen((event) {
    if (kDebugMode) {
      print("onNewEvent: $event");
    }
  });

  ChargerStatus.instance.startPowerChangesListener();
  await _listenToGeoLocations();
}

Future<bool> _listenToGeoLocations() async {
  var status = await _locationService.hasPermission();

  if (status == PermissionStatus.authorizedAlways) {
    if (Platform.isAndroid) {
      _locationService.activateBackgroundMode();

      _locationService.locationStream.listen((event) {
        if (kDebugMode) {
          if (event != null) {
            _timerService.setLocation();
          }
        }
      });
    }
    return true;
  } else {
    return false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    if (kDebugMode) {
      print(e.code + e.description!);
    }
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

  await _listenToGeoLocations();
  ChargerStatus.instance.registerHeadlessDispatcher(callbackDispatcher);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              create: (context) => LocationBloc(
                  locationRepository: context.read<LocationRepository>(),
                  databaseRepository: locator<DatabaseRepository>())
                ..add(GetLocation())),
          BlocProvider(
            create: (context) => ThemeBloc(),
          ),
          BlocProvider(
            create: (context) => ProcessingQueueBloc(
              locator<DatabaseRepository>(),
              locator<ApiRepository>(),
            )..add(ProcessingQueueObserve()),
          ),
          BlocProvider(
            create: (context) => NetworkBloc()
              ..add(NetworkObserve(
                  processingQueueBloc: context.read<ProcessingQueueBloc>())),
          ),
          BlocProvider(
              create: (context) => InitialCubit(locator<ApiRepository>())),
          BlocProvider(create: (context) => PermissionCubit()),
          BlocProvider(create: (context) => PoliticsCubit()),
          BlocProvider(
              create: (context) => LoginCubit(
                  locator<ApiRepository>(),
                  locator<DatabaseRepository>(),
                  locator<LocationRepository>(),
                  BlocProvider.of<ProcessingQueueBloc>(context))),
          BlocProvider(
              create: (context) => HomeCubit(locator<DatabaseRepository>(),
                  locator<ApiRepository>(), locator<LocationRepository>())),
          BlocProvider(
            create: (context) => WorkCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context)),
          ),
          BlocProvider(
            create: (context) => ConfirmCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context)),
          ),
          BlocProvider(
            create: (context) => SummaryCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context)),
          ),
          BlocProvider(
            create: (context) => GeoreferenceCubit(
                locator<DatabaseRepository>(),
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context)),
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
                locator<LocationRepository>(),
                BlocProvider.of<ProcessingQueueBloc>(context)),
          ),
          BlocProvider(
            create: (context) => NavigationCubit(
                locator<DatabaseRepository>(), locator<LocationRepository>()),
          ),
          BlocProvider(
            create: (context) => DatabaseCubit(locator<ApiRepository>()),
          ),
          BlocProvider(
            create: (context) => GeneralCubit(),
          ),
          BlocProvider(
            create: (context) => DownloadCubit(),
          ),
          BlocProvider(
            create: (context) => QueryCubit(locator<DatabaseRepository>()),
          ),
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
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: appTitle,
                  theme: state.isDarkTheme ? AppTheme.light : AppTheme.dark,
                  darkTheme: AppTheme.dark,
                  themeMode: ThemeMode.system,
                  navigatorKey: locator<NavigationService>().navigatorKey,
                  onUnknownRoute: (RouteSettings settings) => MaterialPageRoute(
                      builder: (BuildContext context) => UndefinedView(
                            name: settings.name,
                          )),
                  initialRoute: '/splash',
                  onGenerateRoute: router.generateRoute,
                ),
              );
            })));
  }
}
