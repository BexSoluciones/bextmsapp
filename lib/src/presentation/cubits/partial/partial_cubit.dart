import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

//utils
import '../../../utils/constants/strings.dart';

//domains
import '../../../domain/models/arguments.dart';
import '../../../domain/models/summary.dart';
import '../../../domain/models/reason.dart';
//repositories
import '../../../domain/repositories/database_repository.dart';

//utils
import '../base/base_cubit.dart';

//service
import '../../../locator.dart';
import '../../../services/navigation.dart';

part 'partial_state.dart';

class PartialCubit extends BaseCubit<PartialState, List<ReasonProduct>?> {
  final DatabaseRepository databaseRepository;
  final NavigationService navigationService;

  PartialCubit(this.databaseRepository, this.navigationService)
      : super(const PartialLoading(), null);

  Future<void> init(InventoryArgument arguments) async {
    if (isBusy) return;

    await run(() async {
      final summaries =
          await databaseRepository.getAllSummariesByOrderNumberMoved(
              arguments.work.id!, arguments.summary.orderNumber);

      final reasons = await databaseRepository.getAllReasons();

      final list = summaries
          .map((e) => ReasonProduct(
              index: e.id,
              controller: TextEditingController(),
              summaryId: e.id,
              nameItem: e.nameItem))
          .toList();

      emit(PartialSuccess(
          summaries: summaries, products: list, reasons: reasons));
    });
  }

  Future<void> goToCollection(InventoryArgument arguments) async {
    if (isBusy) return;
    await run(() async {
      final found = state.products!
          .where((element) => element.controller.text.isEmpty)
          .toList();

      if (found.isNotEmpty) {
        emit(PartialFailed(
            summaries: state.summaries,
            products: state.products,
            reasons: state.reasons,
            error: 'Debes completar todos los motivos de devolución'));
      } else {
        arguments.summaries = state.summaries;
        arguments.r = state.products;
        navigationService.goTo(AppRoutes.collection, arguments: arguments);
      }
    });
  }
}
