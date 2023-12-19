//utils
import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/issues/pages/index.dart';
import '../../../presentation/views/user/issues/pages/fill_issues.dart';

Map<String, RouteType> issuesRoutes = {
  AppRoutes.issue: (context, settings) =>
      const IssuesView(),
  AppRoutes.fillIssue: (context, settings) =>
      const FillIssueView(),
};
