import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
//utils
import '../../utils/constants/strings.dart';
//routes
import './separated/auth_routes.dart';
import './separated/home_routes.dart';
import './separated/work_routes.dart';
import './separated/summary_routes.dart';
import './separated/navigation_routes.dart';
import './separated/drawer_routes.dart';
import './separated/issues_routes.dart';
import './separated/developer_routes.dart';
import './separated/core_routes.dart';
import './separated/collection_routes.dart';
//views
import '../../presentation/views/global/undefined_view.dart';

import './route_type.dart';
import './slide_route.dart';

class Routes {
  static Map<String, RouteType> _resolveRoutes() {
    return {
      ...authRoutes,
      ...homeRoutes,
      ...workRoutes,
      ...navigationRoutes,
      ...summaryRoutes,
      ...collectionRoutes,
      ...drawerRoutes,
      ...coreRoutes,
      ...issuesRoutes,
      ...developerRoutes,
    };
  }

  static Route onGenerateRoutes(RouteSettings settings) {
    var routes = _resolveRoutes();
    try {
      final child = routes[settings.name];

      Widget builder(BuildContext c) => child!(c, settings);

      // if (settings.name == AppRoutes.navigation) {
      //   return SlideRoute(builder: builder);
      // }

      return MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
                autoPlayDelay: const Duration(seconds: 3),
                blurValue: 1,
                builder: Builder(builder: builder),
              ));
    } catch (e) {
      print('*******************');
      print(e);
      return MaterialPageRoute(
          builder: (BuildContext context) => UndefinedView(name: settings.name));
    }
  }
}
