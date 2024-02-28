import 'package:bexdeliveries/src/domain/models/summary.dart';
import 'package:bexdeliveries/src/domain/models/summary_report.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../base/base_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'ordersummaryreasons_state.dart';

class OrdersummaryreasonsCubit
    extends BaseCubit<OrdersummaryreasonsState, List<Summary>?> {
  final DatabaseRepository databaseRepository;
  OrdersummaryreasonsCubit(this.databaseRepository)
      : super(const OrdersummaryreasonsLoading(), []);

  Future<void> OrdenSummary(String orderNumber) async {
    if (isBusy) return;
    await run(() async {
      try {
        final summaryRespawn = await databaseRepository
            .getSummaryReportsWithReasonOrRedelivery(orderNumber);
        final summaryReject = await databaseRepository
            .getSummaryReportsWithReturnOrRedelivery(orderNumber);
        final sumarryDelivery =
            await databaseRepository.getSummaryReportsWithDelivery(orderNumber);
        emit(OrdersummaryreasonsSuccess(
            summariesRespawn: summaryRespawn,
            summariesRejects: summaryReject,
            summariesDelivery: sumarryDelivery));
      } catch (error, stackTrace) {
        print('Error data: $error');
        await FirebaseCrashlytics.instance.recordError(error, stackTrace);
        emit(OrdersummaryreasonsFailed(error: error.toString()));
      }
    });
  }
}
