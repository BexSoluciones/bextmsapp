import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:location_repository/location_repository.dart';
import 'package:map_launcher/map_launcher.dart';

//core
import 'package:bexdeliveries/core/helpers/index.dart';

//blocs
import '../../blocs/gps/gps_bloc.dart';
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//utils
import '../../../utils/constants/strings.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/models/summary.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/models/arguments.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/abstracts/format_abstract.dart';

//services
import '../../../locator.dart';
import '../../../services/navigation.dart';

part 'summary_state.dart';

final NavigationService _navigationService = locator<NavigationService>();

class SummaryCubit extends Cubit<SummaryState> with FormatDate {
  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final helperFunctions = HelperFunctions();
  final GpsBloc gpsBloc;

  CurrentUserLocationEntity? currentLocation;

  SummaryCubit(this._databaseRepository, this._locationRepository,
      this._processingQueueBloc, this.gpsBloc)
      : super(const SummaryLoading());

  Future<void> getAllSummariesByOrderNumber(int workId) async {
    emit(await _getAllSummariesByOrderNumber(workId));
  }

  Future<SummaryState> _getAllSummariesByOrderNumber(int workId) async {
    final summaries =
        await _databaseRepository.getAllSummariesByOrderNumber(workId);
    var time = await _databaseRepository.getDiffTime(workId);
    var isArrived =
        await _databaseRepository.validateTransactionArrived(workId, 'arrived');
    var isGeoReferenced = await _databaseRepository.validateClient(workId);

    print('**********');
    print(isGeoReferenced);

    return SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: time,
        isArrived: isArrived,
        isGeoreference: isGeoReferenced);
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

  Future<void> sendTransactionSummary(
      Work work, Summary summary, Transaction transaction) async {
    emit(const SummaryLoading());

    var vts = await _databaseRepository.validateTransactionSummary(
        work.workcode!, summary.orderNumber, 'summary');
    var isArrived = await _databaseRepository.validateTransactionArrived(
        transaction.workId, 'arrived');

    if (isArrived && vts == false) {
      var currentLocation = gpsBloc.state.lastKnownLocation;

      transaction.latitude = currentLocation!.latitude.toString();
      transaction.longitude = currentLocation.longitude.toString();

      var id = await _databaseRepository.insertTransaction(transaction);

      var processingQueue = ProcessingQueue(
          body: jsonEncode(transaction.toJson()),
          task: 'incomplete',
          code: 'store_transaction_summary',
          relation: 'transactions',
          relationId: id.toString(),
          createdAt: now(),
          updatedAt: now());

      _processingQueueBloc
          .add(ProcessingQueueAdd(processingQueue: processingQueue));
    }

    final summaries =
        await _databaseRepository.getAllSummariesByOrderNumber(work.id!);

    emit(SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: state.time,
        isArrived: isArrived,
        isGeoreference: state.isGeoreference));

    _navigationService.goTo(AppRoutes.inventory,
        arguments: InventoryArgument(
            work: work,
            summaryId: summary.id,
            typeOfCharge: summary.typeOfCharge!,
            orderNumber: summary.orderNumber,
            operativeCenter: summary.operativeCenter!,
            summaries: summaries));
  }

  Future<void> sendTransactionArrived(
      Work work, Transaction transaction) async {
    emit(const SummaryLoading());

    var currentLocation = gpsBloc.state.lastKnownLocation;

    transaction.latitude = currentLocation!.latitude.toString();
    transaction.longitude = currentLocation.longitude.toString();

    await _databaseRepository.insertTransaction(transaction);

    var isArrived = await _databaseRepository.validateTransactionArrived(
        transaction.workId, 'arrived');

    var processingQueue = ProcessingQueue(
        body: jsonEncode(transaction.toJson()),
        task: 'incomplete',
        code: 'store_transaction_arrived',
        createdAt: now(),
        updatedAt: now());

    _processingQueueBloc
        .add(ProcessingQueueAdd(processingQueue: processingQueue));

    final summaries =
        await _databaseRepository.getAllSummariesByOrderNumber(work.id!);

    emit(SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: state.time,
        isArrived: isArrived,
        isGeoreference: state.isGeoreference));
  }

  Future<void> showMaps(
      BuildContext context,
      SummaryNavigationArgument arguments,
      DirectionsMode directionsMode) async {
    emit(const SummaryLoadingMap());
    currentLocation ??= await _locationRepository.getCurrentLocation();
    if (context.mounted) {
      helperFunctions.showMapDirection(
          context, arguments.work, currentLocation!);
    }

    emit(const SummaryLoading());
  }
}
