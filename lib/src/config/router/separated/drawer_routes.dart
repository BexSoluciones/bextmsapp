//utils
import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/database/index.dart';
import '../../../presentation/views/user/transaction/index.dart';
import '../../../presentation/views/developer/notifications/index.dart';
import '../../../presentation/views/user/query/features/collection.dart';
import '../../../presentation/views/user/query/features/devolution.dart';
import '../../../presentation/views/user/query/features/respawn.dart';
import '../../../presentation/views/user/query/index.dart';

Map<String, RouteType> drawerRoutes = {
  AppRoutes.database: (context, settings) => const DatabaseView(),
  AppRoutes.transaction: (context, settings) => const TransactionView(),
  AppRoutes.notifications: (context, settings) => const NotificationsView(),
  AppRoutes.query: (context, settings) => const QueryView(),
  AppRoutes.collectionQuery: (context, settings) =>
      CollectionQueryView(workcode: settings.arguments as String),
  AppRoutes.respawnQuery: (context, settings) =>
      RespawnQueryView(workcode: settings.arguments as String),
  AppRoutes.devolutionQuery: (context, settings) =>
      DevolutionQueryView(workcode: settings.arguments as String),
};
