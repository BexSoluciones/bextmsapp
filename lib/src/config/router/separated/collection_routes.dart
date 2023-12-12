//domain
import '../../../domain/models/arguments.dart';
//utils
import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/collection/index.dart';
import '../../../presentation/views/user/partial/index.dart';
import '../../../presentation/views/user/reject/index.dart';
import '../../../presentation/views/user/respawn/index.dart';

Map<String, RouteType> collectionRoutes = {
  AppRoutes.collection: (context, settings) =>
      CollectionView(arguments: settings.arguments as InventoryArgument),
  AppRoutes.partial: (context, settings) =>
      PartialView(arguments: settings.arguments as InventoryArgument),
  AppRoutes.reject: (context, settings) =>
      RejectView(arguments: settings.arguments as InventoryArgument),
  AppRoutes.respawn: (context, settings) =>
      RespawnView(arguments: settings.arguments as InventoryArgument),
};
