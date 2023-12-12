//utils
import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/developer/locations/index.dart';
import '../../../presentation/views/developer/processing_queue/index.dart';
import '../../../presentation/views/developer/transactions/index.dart';

Map<String, RouteType> developerRoutes = {
  AppRoutes.processingQueue: (context, settings) => const ProcessingQueueView(),
  AppRoutes.locations: (context, settings) => const LocationsView(),
  AppRoutes.transactions: (context, settings) => const TransactionsView(),
};
