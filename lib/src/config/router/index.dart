

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//repositories
import '../../domain/models/photo.dart';
import '../../domain/repositories/database_repository.dart';

//utils
import '../../utils/resources/camera.dart';
import '../../utils/constants/strings.dart';

//models
import '../../domain/models/arguments.dart';
import '../../domain/models/work.dart';

//bloc
import '../../presentation/blocs/camera/camera_bloc.dart';

//SCREENS
//global
import '../../presentation/views/global/initial_view.dart';
import '../../presentation/views/global/permission_view.dart';
import '../../presentation/views/global/login_view.dart';
import '../../presentation/views/global/undefined_view.dart';
import '../../presentation/views/global/splash_view.dart';
import '../../presentation/views/global/politics_view.dart';

//user
import '../../presentation/views/user/home/index.dart';
import '../../presentation/views/user/work/index.dart';
import '../../presentation/views/user/confirm/index.dart';
import '../../presentation/views/user/navigation/index.dart';
import '../../presentation/views/user/summary/index.dart';
import '../../presentation/views/user/summary/features/navigation.dart';
import '../../presentation/views/user/summary/features/georeference.dart';
import '../../presentation/views/user/inventory/index.dart';
import '../../presentation/views/user/collection/index.dart';
import '../../presentation/views/user/camera/index.dart';
import '../../presentation/views/user/collection/features/firm.dart';
import '../../presentation/views/user/partial/index.dart';
import '../../presentation/views/user/reject/index.dart';
import '../../presentation/views/user/respawn/index.dart';
import '../../presentation/views/user/transaction/index.dart';
import '../../presentation/views/user/query/index.dart';
import '../../presentation/views/user/query/features/devolution.dart';
import '../../presentation/views/user/query/features/respawn.dart';
import '../../presentation/views/user/query/features/collection.dart';
import '../../presentation/views/user/database/index.dart';
import '../../presentation/views/user/photos/index.dart';
import '../../presentation/views/user/photos/features/detail.dart';

//developer
import '../../presentation/views/developer/processing_queue/index.dart';
import '../../presentation/views/developer/locations/index.dart';

//locator
import '../../locator.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case splashRoute:
      return MaterialPageRoute(builder: (context) => const SplashView());
    case politicsRoute:
      return MaterialPageRoute(builder: (context) => const PoliticsView());
    case permissionRoute:
      return MaterialPageRoute(
          builder: (context) => const RequestPermissionView());
    case companyRoute:
      return MaterialPageRoute(builder: (context) => const InitialView());
    case loginRoute:
      return MaterialPageRoute(builder: (context) => const LoginView());
    //user routes
    case homeRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return const HomeView();
              })));
    case workRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return WorkView(arguments: settings.arguments as WorkArgument);
              })));
    case confirmRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return ConfirmWorkView(
                    arguments: settings.arguments as WorkArgument);
              })));
    case navigationRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return NavigationView(workcode: settings.arguments as String);
              })));
    case summaryRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return SummaryView(
                    arguments: settings.arguments as SummaryArgument);
              })));
    case summaryNavigationRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return SummaryNavigationView(
                    arguments: settings.arguments as SummaryNavigationArgument);
              })));
    case summaryGeoreferenceRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return SummaryGeoreferenceView(
                    work: settings.arguments as Work);
              })));
    case inventoryRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return InventoryView(
                    arguments: settings.arguments as InventoryArgument);
              })));
    case collectionRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return CollectionView(
                    arguments: settings.arguments as InventoryArgument);
              })));
    case partialRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return PartialView(
                    arguments: settings.arguments as InventoryArgument);
              })));
    case rejectRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return RejectView(
                    arguments: settings.arguments as InventoryArgument);
              })));
    case respawnRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return RespawnView(
                    arguments: settings.arguments as InventoryArgument);
              })));
    case firmRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                return FirmView(orderNumber: settings.arguments as String);
              })));
    case cameraRoute:
      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              autoPlayDelay: const Duration(seconds: 3),
              blurValue: 1,
              builder: Builder(builder: (context) {
                // return CameraView(orderNumber: settings.arguments as String);
                return BlocProvider(
                  create: (_) => CameraBloc(cameraUtils: CameraUtils(), databaseRepository: locator<DatabaseRepository>())
                    ..add(CameraInitialized()),
                  child: CameraView(),
                );
              })));
    case photoRoute:
      return MaterialPageRoute(builder: (context) => const PhotoView());
    case detailPhotoRoute:
      return MaterialPageRoute(builder: (context) => DetailPhotoView(
        photo: settings.arguments as Photo,
      ));
    //drawer routes
    case databaseRoute:
      return MaterialPageRoute(builder: (context) => const DatabaseView());
    case processingQueueRoute:
      return MaterialPageRoute(
          builder: (context) => const ProcessingQueueView());
    case locationsRoute:
      return MaterialPageRoute(builder: (context) => const LocationsView());
    case transactionRoute:
      return MaterialPageRoute(builder: (context) => const TransactionView());
    case queryRoute:
      return MaterialPageRoute(builder: (context) => const QueryView());
    case collectionQueryRoute:
      return MaterialPageRoute(
          builder: (context) =>
              CollectionQueryView(workcode: settings.arguments as String));
    case devolutionQueryRoute:
      return MaterialPageRoute(
          builder: (context) =>
              DevolutionQueryView(workcode: settings.arguments as String));
    case respawnQueryRoute:
      return MaterialPageRoute(
          builder: (context) =>
              RespawnQueryView(workcode: settings.arguments as String));
    default:
      return MaterialPageRoute(
          builder: (context) => UndefinedView(
                name: settings.name,
              ));
  }
}
