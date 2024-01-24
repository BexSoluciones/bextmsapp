//utils

import 'package:bexdeliveries/src/domain/models/processing_queue.dart';

import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/developer/locations/index.dart';
import '../../../presentation/views/developer/processing_queue/index.dart';
import '../../../presentation/views/developer/processing_queue/features/detail.dart';
import '../../../presentation/views/developer/transactions/index.dart';

Map<String, RouteType> developerRoutes = {
  AppRoutes.processingQueue: (context, settings) => const ProcessingQueueView(),
  AppRoutes.processingQueueDetail: (context, settings) =>
      ProcessingQueueCardDetail(
          processingQueue: settings.arguments as ProcessingQueue),
  AppRoutes.locations: (context, settings) => const LocationsView(),
  AppRoutes.transactions: (context, settings) => const TransactionsView(),
};
