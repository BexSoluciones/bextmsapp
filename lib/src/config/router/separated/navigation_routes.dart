//utils
import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/navigation/index.dart';

Map<String, RouteType> navigationRoutes = {
  AppRoutes.navigation: (context, settings) =>
      NavigationView(workcode: settings.arguments as String),
};
