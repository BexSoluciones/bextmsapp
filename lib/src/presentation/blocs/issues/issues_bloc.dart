import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

//core
import '../../../../core/helpers/index.dart';

//blocs
import '../../blocs/gps/gps_bloc.dart';
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//domain
import '../../../domain/models/news.dart';
import '../../../domain/models/reason.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/abstracts/format_abstract.dart';

//services
import '../../../locator.dart';
import '../../../services/storage.dart';

part 'issues_event.dart';
part 'issues_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> with FormatDate {
  final DatabaseRepository _databaseRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final GpsBloc gpsBloc;
  final helperFunctions = HelperFunctions();

  IssuesBloc(this._databaseRepository, this._processingQueueBloc, this.gpsBloc)
      : super(IssuesState()) {
    on<GetIssuesList>(_getIssuesList);
    on<GetUserId>(_getUserId);
    on<SelectIssue>(_selectIssue);
    on<SearchIssue>(_searchIssue);
    on<RequestUserWorkId>(_requestWorkId);
    on<ChangeObservations>(_changeObservations);
    on<ChangeFirm>(_changeFirm);
    on<ChangePhotos>(_changePhotos);
    on<DataIssue>(send);
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

  void send(DataIssue event, Emitter emit) async {
    var location = gpsBloc.state.lastKnownLocation;

    var firmApplication = await helperFunctions.getFirm(
        'firm-${(state.status == 'work') ? state.workId.toString() + state.codmotvis! : (state.status == 'summary') ? state.selectedSummaryId.toString() + state.codmotvis! : _storageService.getInt('user_id')!.toString() + state.codmotvis!}');

    var images = await helperFunctions.getImages((state.status == 'work')
        ? state.workId.toString() + state.codmotvis!
        : (state.status == 'summary')
            ? state.selectedSummaryId.toString() + state.codmotvis!
            : _storageService.getInt('user_id')!.toString() + state.codmotvis!);

    var imagesPath = <String>[];
    var firmApplicationPath = <String>[];

    if (firmApplication != null) {
      List<int> imageBytes = firmApplication.readAsBytesSync();
      var base64Image = base64Encode(imageBytes);
      firmApplicationPath.add(base64Image);
    }

    if (images.isNotEmpty) {
      for (var element in images) {
        List<int> imageBytes = element.readAsBytesSync();
        var base64Image = base64Encode(imageBytes);
        imagesPath.add(base64Image);
      }
    }

    var news = News(
        status: state.status!,
        userId: _storageService.getInt('user_id')!,
        workId: (state.status == 'summary' || state.status == 'general')
            ? null
            : state.workId,
        summaryId: (state.status == 'work' || state.status == 'general')
            ? null
            : state.selectedSummaryId,
        nommotvis: state.nommotvis!,
        codmotvis: state.codmotvis!,
        latitude: location!.latitude.toString(),
        longitude: location.longitude.toString(),
        images: imagesPath,
        firm: firmApplicationPath,
        observation: state.observations!.text);

    _databaseRepository.insertNews(news);

    var processingQueue = ProcessingQueue(
        body: jsonEncode(news.toJson()),
        task: 'incomplete',
        code: 'store_news',
        createdAt: now(),
        updatedAt: now());

    _processingQueueBloc
        .add(ProcessingQueueAdd(processingQueue: processingQueue));
    await helperFunctions.deleteImages("");
    await helperFunctions.deleteFirm('');

    if (news.firm != null) {
      news.firm = jsonEncode(firmApplicationPath);
    }
    if (news.images != null) {
      news.images = jsonEncode(imagesPath);
    }

    if (state.selectedIssue?.tipocliente != null &&
        state.selectedIssue?.tipocliente.toLowerCase() == 'unlock' &&
        state.selectedIssue!.codmotvis == '01') {
      _storageService.setBool(
          '${state.selectedSummaryId}-distance_ignore', true);
    }
  }
}
