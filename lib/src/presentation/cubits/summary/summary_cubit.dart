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
import '../../../domain/models/enterprise_config.dart';
import '../../../domain/models/arguments.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/abstracts/format_abstract.dart';

//services
import '../../../locator.dart';
import '../../../services/navigation.dart';
import '../../../services/storage.dart';

part 'summary_state.dart';

final NavigationService _navigationService = locator<NavigationService>();
final LocalStorageService _storageService = locator<LocalStorageService>();

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

    return SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: time,
        isArrived: isArrived,
        isGeoReference: isGeoReferenced);
  }

  Future<List> countBox(String orderNumber) async {
    final summaryFutures = await Future.wait([
      _databaseRepository.getTotalPackageSummaries(orderNumber),
      _databaseRepository.getTotalPackageSummariesLoose(orderNumber),
    ]);

    return summaryFutures;
  }

  Future<void> getDiffTime(int workId) async {
    var time = await _databaseRepository.getDiffTime(workId);
    emit(SummarySuccess(
        summaries: state.summaries,
        origin: state.origin,
        time: time,
        isArrived: state.isArrived,
        isGeoReference: state.isGeoReference));
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
        isGeoReference: state.isGeoReference));

    _navigationService.goTo(AppRoutes.inventory,
        arguments: InventoryArgument(
            work: work, summary: summary, summaries: summaries));
  }

  bool validateDistance(currentLocation, lat, log, summaryId) {
    if (_storageService.getBool('$summaryId-distance_ignore') != null &&
        _storageService.getBool('$summaryId-distance_ignore') == true) {
      return true;
    } else {
      return helperFunctions.isWithinRadiusGeo(currentLocation, lat, log);
    }
  }

  Future<void> sendTransactionArrived(
      BuildContext context, Work work, Transaction transaction) async {
    emit(const SummaryLoading());

    var currentLocation = gpsBloc.state.lastKnownLocation;

    transaction.latitude = currentLocation!.latitude.toString();
    transaction.longitude = currentLocation.longitude.toString();

    final enterpriseConfig = _storageService.getObject('config') != null
        ? EnterpriseConfig.fromMap(_storageService.getObject('config')!)
        : null;

    if (enterpriseConfig != null &&
        enterpriseConfig.fixedDeliveryDistance == true) {
      var distanceInMeters = helperFunctions.calculateDistanceInMetersGeo(
          currentLocation,
          double.tryParse(work.latitude!)!,
          double.tryParse(work.longitude!)!);

      if (!validateDistance(currentLocation, work.latitude, work.longitude,
          transaction.summaryId) && context.mounted) {
        helperFunctions.showDialogWithDistance(context, distanceInMeters);
      }
    }

    await _databaseRepository.insertTransaction(transaction);

    var isArrived = await _databaseRepository.validateTransactionArrived(
        transaction.workId, 'arrived');

    var isGeoReferenced =
        await _databaseRepository.validateClient(transaction.workId);

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
        isGeoReference: isGeoReferenced));
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

    final summaries = await _databaseRepository
        .getAllSummariesByOrderNumber(arguments.work.id!);

    var isArrived = await _databaseRepository.validateTransactionArrived(
        arguments.work.id!, 'arrived');

    var isGeoReferenced =
        await _databaseRepository.validateClient(arguments.work.id!);

    emit(SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: state.time,
        isArrived: isArrived,
        isGeoReference: isGeoReferenced));
  }

  Future<void> error(int id, String error) async {
    final summaries =
        await _databaseRepository.getAllSummariesByOrderNumber(id);

    var isArrived =
        await _databaseRepository.validateTransactionArrived(id, 'arrived');

    var isGeoReferenced = await _databaseRepository.validateClient(id);

    emit(SummaryFailed(
        error: error,
        summaries: summaries,
        origin: state.origin,
        time: state.time,
        isArrived: isArrived,
        isGeoReference: isGeoReferenced));
  }
}
