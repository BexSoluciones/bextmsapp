import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:location_repository/location_repository.dart';

//cubit
import '../base/base_cubit.dart';

//bloc
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/abstracts/format_abstract.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';

part 'work_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class WorkCubit extends BaseCubit<WorkState, List<Work>> with FormatDate {
  final DatabaseRepository _databaseRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final LocationRepository _locationRepository;

  CurrentUserLocationEntity? currentLocation;

  WorkCubit(
      this._databaseRepository, this._locationRepository, this._processingQueueBloc)
      : super(const WorkLoading(), []);

  int page = 0;

  Future<void> getAllWorksByWorkcode(String workcode, bool needRebuild) async {

    if (isBusy) return;

    await run(() async {

      // final total = await _databaseRepository.countAllWorksByWorkcode(workcode);
      final works = await _databaseRepository.findAllWorksByWorkcode(workcode);

      print(works.length);

      if(needRebuild){
        data = [];
      }

      var started = _storageService.getBool('$workcode-started');
      var confirm = _storageService.getBool('$workcode-confirm');

      data = works;

      final visited = data
          .where((element) =>
              element.hasCompleted != null && element.hasCompleted == 1)
          .toList();

      final notVisited = data
          .where((element) =>
              element.hasCompleted != null && element.hasCompleted == 0)
          .toList();

      final notGeoreferenced = data
          .where((element) =>
              element.latitude == null && element.longitude == null)
          .toList();

      emit(WorkSuccess(
          workcode: workcode,
          works: data,
          visited: visited,
          notVisited: notVisited,
          notGeoreferenced: notGeoreferenced,
          // noMoreData: noMoreData,
          started: started ?? false,
          confirm: confirm ?? false));
    });
  }

  void changeStarted(String workcode, bool data) {
    _storageService.setBool('$workcode-started', data);
    emit(WorkSuccess(
        works: state.works,
        confirm: state.confirm,
        started: data));
  }

  void changeConfirm(String workcode, bool data) {
    _storageService.setBool('$workcode-confirm', data);
    emit(WorkSuccess(
        works: state.works,
        visited: state.visited,
        notVisited: state.notVisited,
        notGeoreferenced: state.notGeoreferenced,
        started: state.started,
        confirm: data));
  }

}
