import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

//domain
import '../../../domain/models/reason.dart';
import '../../../domain/repositories/database_repository.dart';

part 'issues_event.dart';
part 'issues_state.dart';

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {

  final DatabaseRepository _databaseRepository;

  IssuesBloc(this._databaseRepository) : super(IssuesState()) {
    on<GetIssuesList>(_getIssuesList);
    on<GetUserId>(_getUserId);
    on<SelectIssue>(_selectIssue);
    on<SearchIssue>(_searchIssue);
    on<RequestUserWorkId>(_requestWorkId);
    on<ChangeObservations>(_changeObservations);
    on<ChangeFirm>(_changeFirm);
    on<ChangePhotos>(_changePhotos);
  }

  void _getIssuesList(GetIssuesList event, Emitter emit) async {
    List<Reason> listReasonsToShow;
    listReasonsToShow = [];
    List<Reason> listReasons;
    listReasons = await _databaseRepository.getAllReasons();

    if (event.currentStatus == 'general') {
      for (var element in listReasons) {
        if (element.tipocliente.toLowerCase() == 'general') {
          listReasonsToShow.add(element);
        }
      }
    }

    if (event.currentStatus == 'summary') {
      for (var element in listReasons) {
        if (element.tipocliente.toLowerCase() == 'general' ||
            element.tipocliente.toLowerCase() == 'unlock') {
          listReasonsToShow.add(element);
        }
      }
    }

    if (event.currentStatus == 'work') {
      for (var element in listReasons) {
        if (element.tipocliente.toLowerCase() == 'general') {
          listReasonsToShow.add(element);
        }
      }
    }

    emit(state.copyWith(
        issuesList: listReasonsToShow,
        immutableIssuesList: listReasons,
        currentStatus: event.currentStatus,
        status: event.currentStatus,
        workId: event.workId,
        selectedSummaryId: event.summaryId));
  }

  void _requestWorkId(RequestUserWorkId event, Emitter emit) {
    emit(state.copyWith(clientWorkId: event.userWorkId));
  }

  void _selectIssue(SelectIssue event, Emitter emit) {
    emit(state.copyWith(
        selectedIssue: event.newSelectedIssue,
        codmotvis: event.newSelectedIssue.codmotvis,
        nommotvis: event.newSelectedIssue.nommotvis));
  }

  void _changeObservations(ChangeObservations event, Emitter emit) {
    emit(state.copyWith(observations: event.observations));
  }

  void _changeFirm(ChangeFirm event, Emitter emit) {
    emit(state.copyWith(firm: event.firm));
  }

  void _changePhotos(ChangePhotos event, Emitter emit) {
    emit(state.copyWith(images: event.photos));
  }

  void _getUserId(GetUserId event, Emitter emit) {
    emit(state.copyWith(userId: int.parse(event.userId)));
  }

  void _searchIssue(SearchIssue event, Emitter emit) {
    final result = state.immutableIssuesList!.where((issue) {
      var fullIssue =
          '${issue.codmotvis.toLowerCase()} ${issue.nommotvis.toLowerCase()}';
      final titleLower = fullIssue.toLowerCase();
      final searchLower = event.issueToSearch.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();

    emit(state.copyWith(issuesList: result));
  }
}
