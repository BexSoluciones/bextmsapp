import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_repository/location_repository.dart';

//blocs
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/models/summary.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/abstracts/format_abstract.dart';

part 'summary_state.dart';

class SummaryCubit extends Cubit<SummaryState> with FormatDate {

  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;
  final ProcessingQueueBloc _processingQueueBloc;

  CurrentUserLocationEntity? currentLocation;

  SummaryCubit(this._databaseRepository, this._locationRepository, this._processingQueueBloc)
      : super(const SummaryLoading());

  Future<void> getAllSummariesByOrderNumber(int workId) async {
    emit(await _getAllSummariesByOrderNumber(workId));
  }

  Future<SummaryState> _getAllSummariesByOrderNumber(int workId) async {
    final summaries = await _databaseRepository.getAllSummariesByOrderNumber(workId);
    var time = await _databaseRepository.getDiffTime(workId);
    var isArrived = await _databaseRepository.validateTransactionArrived(workId, 'arrived');

    return SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: time,
        isArrived: isArrived,
        isGeoreference: state.isGeoreference);
  }

  Future<void> getDiffTime(int workId) async {
    var time = await _databaseRepository.getDiffTime(workId);
    emit(SummarySuccess(
        summaries: state.summaries,
        origin: state.origin,
        time: time,
        isArrived: state.isArrived,
        isGeoreference: state.isGeoreference));
  }

  Future<void> sendTransactionArrived(Work work, Transaction transaction) async {
    emit(const SummaryLoading());

    currentLocation ??= await _locationRepository.getCurrentLocation();

    transaction.latitude = currentLocation!.latitude.toString();
    transaction.longitude = currentLocation!.longitude.toString();

    await _databaseRepository.insertTransaction(transaction);

    var isArrived = await _databaseRepository.validateTransactionArrived(transaction.workId, 'arrived');

    var processingQueue = ProcessingQueue(
        body: jsonEncode(transaction.toJson()),
        task: 'incomplete',
        code: 'LLKFNVLKNE',
        createdAt: now(),
        updatedAt: now());

    _processingQueueBloc.add(ProcessingQueueAdd(processingQueue: processingQueue));

    final summaries = await _databaseRepository.getAllSummariesByOrderNumber(work.id!);

    emit(SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: state.time,
        isArrived: isArrived,
        isGeoreference: state.isGeoreference));
  }
}
