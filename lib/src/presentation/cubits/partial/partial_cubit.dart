import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

//utils
import '../../../utils/constants/strings.dart';

//domains
import '../../../domain/models/arguments.dart';
import '../../../domain/models/summary.dart';
import '../../../domain/models/reason.dart';
//repositories
import 'package:location_repository/location_repository.dart';
import '../../../domain/repositories/database_repository.dart';

//blocs
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//utils
import '../base/base_cubit.dart';

//service
import '../../../locator.dart';
import '../../../services/navigation.dart';

part 'partial_state.dart';

final NavigationService _navigationService  = locator<NavigationService>();

class PartialCubit extends BaseCubit<PartialState, List<ReasonProduct>?> {
  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;
  final ProcessingQueueBloc _processingQueueBloc;

  PartialCubit(this._databaseRepository, this._locationRepository,
      this._processingQueueBloc)
      : super(const PartialLoading(), null);

  Future<void> init(InventoryArgument arguments) async {
    if (isBusy) return;

    await run(() async {
      final summaries =
          await _databaseRepository.getAllSummariesByOrderNumberMoved(
              arguments.work.id!, arguments.orderNumber);

      final reasons = await _databaseRepository.getAllReasons();

      final list = summaries
          .map((e) => ReasonProduct(
              index: e.id,
              controller: TextEditingController(),
              summaryId: e.id,
              nameItem: e.nameItem))
          .toList();

      emit(PartialSuccess(summaries: summaries, products: list, reasons: reasons));
    });
  }

  Future<void> goToCollection(InventoryArgument arguments) async {
    if (isBusy) return;
    await run(() async {
      final found = state.products!.where((element) => element.controller.text.isEmpty).toList();

      if(found.isNotEmpty){
        emit(PartialFailed(summaries: state.summaries, reasons: state.reasons, error: 'Debes completar todos los motivos de devolución'));
      } else {
        arguments.summaries = state.summaries;
        arguments.r = state.products;
        _navigationService.goTo(AppRoutes.collection, arguments: arguments);
      }
    });
  }
}
