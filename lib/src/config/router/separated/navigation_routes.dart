import 'package:latlong2/latlong.dart';
//utils
import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/navigation/index.dart';
import '../../../presentation/views/user/notes/index.dart';

Map<String, RouteType> navigationRoutes = {
  AppRoutes.navigation: (context, settings) =>
      NavigationView(workcode: settings.arguments as String),
  AppRoutes.notes: (context, settings) =>
      NotesView(position: settings.arguments as LatLng),
};
