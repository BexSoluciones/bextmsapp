import 'dart:async';
import 'package:equatable/equatable.dart';

//cubit
import '../base/base_cubit.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/abstracts/format_abstract.dart';

//service
import '../../../services/storage.dart';

part 'work_state.dart';

class WorkCubit extends BaseCubit<WorkState, List<Work>> with FormatDate {
  final DatabaseRepository databaseRepository;
  final LocalStorageService storageService;

  WorkCubit(this.databaseRepository, this.storageService)
      : super(const WorkLoading(), []);

  int page = 0;

  Future<void> getAllWorksByWorkcode(String workcode, bool needRebuild) async {
    if (isBusy) return;

    await run(() async {
      final works = await databaseRepository.findAllWorksByWorkcode(workcode);

      if (needRebuild) {
        data = [];
      }

      var started = storageService.getBool('$workcode-started');
      var confirm = storageService.getBool('$workcode-confirm');

      data = works;

      for (var d in data) {
        d.summaries = await databaseRepository.getAllSummariesByWorkcode(
            d.id!, d.customer!);
      }

      final visited = data
          .where((element) =>
              element.hasCompleted != null && element.hasCompleted == 1)
          .toList();

      final notVisited = data
          .where((element) =>
              element.hasCompleted != null && element.hasCompleted == 0)
          .toList();

      final notGeoReferenced = data
          .where((element) =>
              element.latitude == null && element.longitude == null)
          .toList();

      emit(WorkSuccess(
          workcode: workcode,
          works: data,
          visited: visited,
          notVisited: notVisited,
          notGeoreferenced: notGeoReferenced,
          // noMoreData: noMoreData,
          started: started ?? false,
          confirm: confirm ?? false));
    });
  }

  void changeStarted(String workcode, bool data) {
    storageService.setBool('$workcode-started', data);
    emit(
        WorkSuccess(works: state.works, confirm: state.confirm, started: data));
  }

  void changeConfirm(String workcode, bool data) {
    storageService.setBool('$workcode-confirm', data);
    emit(WorkSuccess(
        works: state.works,
        visited: state.visited,
        notVisited: state.notVisited,
        notGeoreferenced: state.notGeoreferenced,
        started: state.started,
        confirm: data));
  }
}
