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
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'history_order_event.dart';
part 'history_order_state.dart';

class HistoryOrderBloc extends Bloc<HistoryOrderEvent, HistoryOrderState>
    with FormatDate {
  final DatabaseRepository databaseRepository;
  final ProcessingQueueBloc processingQueueBloc;
  final LocalStorageService storageService;
  final NavigationService navigationService;

  HistoryOrderBloc(this.databaseRepository, this.processingQueueBloc,
      this.storageService, this.navigationService)
      : super(HistoryOrderInitial()) {
    on<HistoryOrderInitialRequest>(_requestHistory);
    on<ChangeCurrentWork>(_changeCurrentWork);
  }

  HistoryOrder? historyOrder;

  Future<void> _requestHistory(
    HistoryOrderInitialRequest event,
    Emitter<HistoryOrderState> emit,
  ) async {
    if (storageService.getBool('${event.work.workcode}-oneOrMoreFinished') ==
        true) {
      await navigationService.goTo(AppRoutes.work,
          arguments: WorkArgument(
            work: event.work,
          ));
    }

    emit(HistoryOrderLoading());

    historyOrder = await databaseRepository.getHistoryOrder(
        event.work.workcode!, event.work.zoneId ?? 0);

    if (historyOrder != null) {
      emit(HistoryOrderShow(historyOrder: historyOrder));

      bool? showAgain;
      showAgain = storageService.getBool('${event.work.workcode}-showAgain');

      (historyOrder != null && showAgain == false)
          ? await navigationService.goTo(AppRoutes.history,
              arguments: HistoryArgument(
                  work: event.work,
                  likelihood: historyOrder!.likelihood!,
                  differents: historyOrder!.different))
          : await navigationService.goTo(AppRoutes.work,
              arguments: WorkArgument(work: event.work));
    } else {
      await navigationService.goTo(AppRoutes.work,
          arguments: WorkArgument(work: event.work));

      emit(HistoryOrderError(error: 'Error obteniendo el historico'));
    }
  }

  void _changeCurrentWork(
    ChangeCurrentWork event,
    Emitter<HistoryOrderState> emit,
  ) async {
    emit(HistoryOrderLoading());

    await databaseRepository.insertWorks(historyOrder!.works);

    useHistoric(event.work.workcode!, historyOrder!.id!);

    emit(HistoryOrderChanged(historyOrder: historyOrder));

    await navigationService.goTo(AppRoutes.work,
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

    processingQueueBloc
        .add(ProcessingQueueAdd(processingQueue: processingQueue));

    processingQueue = ProcessingQueue(
        body: jsonEncode({'workcode': workcode, 'count': 1}),
        task: 'incomplete',
        code: 'update_history_order',
        createdAt: now(),
        updatedAt: now());

    processingQueueBloc
        .add(ProcessingQueueAdd(processingQueue: processingQueue));

    storageService.setBool('$workcode-routing', true);
    storageService.setBool('$workcode-historic', true);
  }
}
