//domain
import '../../../domain/models/arguments.dart';
//utils
import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/summary/index.dart';
import '../../../presentation/views/user/summary/features/geo-reference.dart';
import '../../../presentation/views/user/summary/features/navigation.dart';
import '../../../presentation/views/user/inventory/index.dart';
import '../../../presentation/views/user/package/index.dart';

Map<String, RouteType> summaryRoutes = {
  AppRoutes.summary: (context, settings) =>
      SummaryView(arguments: settings.arguments as SummaryArgument),
  AppRoutes.summaryGeoReference: (context, settings) =>
      SummaryGeoReferenceView(argument: settings.arguments as SummaryArgument),
  AppRoutes.summaryNavigation: (context, settings) => SummaryNavigationView(
      arguments: settings.arguments as SummaryNavigationArgument),
  AppRoutes.inventory: (context, settings) => InventoryView(
      arguments: settings.arguments as InventoryArgument),
  AppRoutes.package: (context, settings) => PackageView(
      arguments: settings.arguments as PackageArgument),
};
