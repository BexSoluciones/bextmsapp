//utils
import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/global/splash_view.dart';
import '../../../presentation/views/global/login_view.dart';
import '../../../presentation/views/global/initial_view.dart';
import '../../../presentation/views/global/permission_view.dart';

Map<String, RouteType> authRoutes = {
  AppRoutes.splash: (context, settings) => const SplashView(),
  AppRoutes.politics: (context, settings) => const LoginView(),
  AppRoutes.company: (context, settings) => const InitialView(),
  AppRoutes.permission: (context, settings) => const RequestPermissionView(),
  AppRoutes.login: (context, settings) => const LoginView(),
};