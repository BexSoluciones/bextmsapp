import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_repository/location_repository.dart';

//blocs
import '../processing_queue/processing_queue_bloc.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/repositories/database_repository.dart';

//service

import '../../../locator.dart';
import '../../../services/storage.dart';

part 'work_state.dart';
part 'work_event.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class WorkBloc extends Bloc<WorkEvent, WorkState> {
  final DatabaseRepository _databaseRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final LocationRepository _locationRepository;

  CurrentUserLocationEntity? currentUserLocationEntity;

  WorkBloc(this._databaseRepository, this._locationRepository,
      this._processingQueueBloc)
      : super(Initial()) {
    on<ConfirmWorkEvent>(_confirm);
    on<GetWorksEvent>(_observe);
  }

  void _confirm(event, emit) async {}

  void _observe(event, emit) async {
    final total =
        await _databaseRepository.countAllWorksByWorkcode(event.workcode);
    final works = await _databaseRepository.findAllWorksPaginatedByWorkcode(
        event.workcode, 1);

    var started = _storageService.getBool('${event.workcode}-started');
    var blocked = _storageService.getBool('${event.workcode}-blocked');
    var confirm = _storageService.getBool('${event.workcode}-confirm');

    var noMoreData = works.length == total;

    final visited = works
        .where((element) =>
            element.hasCompleted != null && element.hasCompleted == 1)
        .toList();

    final notVisited = works
        .where((element) =>
            element.hasCompleted != null && element.hasCompleted == 0)
        .toList();

    final notGeoreferenced = works
        .where(
            (element) => element.latitude == null && element.longitude == null)
        .toList();

    emit(Loaded(
        workcode: event.workcode,
        works: works,
        visited: visited,
        notVisited: notVisited,
        notGeoreferenced: notGeoreferenced,
        noMoreData: noMoreData,
        started: started ?? false,
        blocked: blocked ?? false,
        confirm: confirm ?? false));
  }

  void changeStarted(event, emit) {
    _storageService.setBool('${event.workcode}-started', event.data);
    emit(Loaded(
        works: state.works,
        confirm: state.confirm,
        blocked: state.blocked,
        started: event.data));
  }

  Stream<WorkState> mapEventToState(
    WorkEvent event,
  ) async* {
    if (event is ConfirmWorkEvent) {
      yield Loading();
    }
  }
}
