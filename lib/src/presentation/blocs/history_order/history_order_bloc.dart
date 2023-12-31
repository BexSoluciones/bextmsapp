import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

//bloc
import '../processing_queue/processing_queue_bloc.dart';

//utils
import '../../../utils/constants/strings.dart';

//domain
import '../../../domain/models/history_order.dart';
import '../../../domain/models/arguments.dart';
import '../../../domain/models/work.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/abstracts/format_abstract.dart';
import '../../../domain/repositories/database_repository.dart';

//services
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'history_order_event.dart';
part 'history_order_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();

class HistoryOrderBloc extends Bloc<HistoryOrderEvent, HistoryOrderState> with FormatDate {

  final DatabaseRepository _databaseRepository;
  final ProcessingQueueBloc _processingQueueBloc;

  HistoryOrderBloc(this._databaseRepository, this._processingQueueBloc)
      : super(HistoryOrderInitial()) {
    on<HistoryOrderInitialRequest>(_requestHistory);
    on<ChangeCurrentWork>(_changeCurrentWork);
  }

  HistoryOrder? historyOrder;


  Future<void> _requestHistory(
    HistoryOrderInitialRequest event,
    Emitter<HistoryOrderState> emit,
  ) async {
    if (_storageService.getBool('${event.work.workcode}-oneOrMoreFinished') ==
        true) {
      await _navigationService.goTo(AppRoutes.work,
          arguments: WorkArgument(
            work: event.work,
          ));
    }

    emit(HistoryOrderLoading());

    historyOrder = await _databaseRepository.getHistoryOrder(
        event.work.workcode!, event.work.zoneId ?? 0);

    if (historyOrder != null) {
      emit(HistoryOrderShow(historyOrder: historyOrder));

      bool? showAgain;
      showAgain = _storageService.getBool('${event.work.workcode}-showAgain');

      (historyOrder != null && showAgain == false)
          ? await _navigationService.goTo(AppRoutes.history, arguments: historyOrder)
          : await _navigationService.goTo(AppRoutes.work,
              arguments: WorkArgument(work: event.work));
    } else {
      await _navigationService.goTo(AppRoutes.work,
          arguments: WorkArgument(work: event.work));

      emit(HistoryOrderError(error: 'Error obteniendo el historico'));
    }
  }

  void _changeCurrentWork(
    ChangeCurrentWork event,
    Emitter<HistoryOrderState> emit,
  ) async {
    emit(HistoryOrderLoading());

    await _databaseRepository.insertWorks(historyOrder!.works);

    useHistoric(event.work.workcode!, historyOrder!.id!);

    emit(HistoryOrderChanged(historyOrder: historyOrder));

    await _navigationService.goTo(AppRoutes.work,
        arguments: WorkArgument(work: event.work));
  }

  Future<void> useHistoric(
    String workcode,
    int historyId,
  ) async {
    var processingQueue = ProcessingQueue(
      body: jsonEncode({'workcode': workcode, 'history_id': historyId}),
      task: 'incomplete',
      code: 'post_new_routing',
      createdAt: now(),
      updatedAt: now(),
    );

    _processingQueueBloc
        .add(ProcessingQueueAdd(processingQueue: processingQueue));

    processingQueue = ProcessingQueue(
        body: jsonEncode({'workcode': workcode, 'count': 1}),
        task: 'incomplete',
        code: 'update_history_order',
        createdAt: now(),
        updatedAt: now());

    _processingQueueBloc
        .add(ProcessingQueueAdd(processingQueue: processingQueue));

    _storageService.setBool('$workcode-routing', true);
    _storageService.setBool('$workcode-historic', true);
  }
}
