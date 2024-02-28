//utils
import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/home/index.dart';

Map<String, RouteType> homeRoutes = {
  AppRoutes.home: (context, settings) =>
      HomeView(navigation: settings.arguments as String)
};
