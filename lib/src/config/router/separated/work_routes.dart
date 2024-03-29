//domain
import '../../../domain/models/arguments.dart';
//utils

import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/work/index.dart';
import '../../../presentation/views/user/confirm/index.dart';
import '../../../presentation/views/user/history/index.dart';

Map<String, RouteType> workRoutes = {
  AppRoutes.work: (context, settings) =>
      WorkView(arguments: settings.arguments as WorkArgument),
  AppRoutes.confirm: (context, settings) =>
      ConfirmWorkView(arguments: settings.arguments as WorkArgument),
  AppRoutes.history: (context, settings) =>
      HistoryView(arguments: settings.arguments as HistoryArgument)
};
