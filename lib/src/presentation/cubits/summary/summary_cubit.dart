import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
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
import '../../../services/navigation.dart';
import '../../../services/storage.dart';
import '../../../services/logger.dart';

part 'summary_state.dart';

class SummaryCubit extends Cubit<SummaryState> with FormatDate {
  final DatabaseRepository databaseRepository;
  final ProcessingQueueBloc processingQueueBloc;
  final helperFunctions = HelperFunctions();
  final GpsBloc gpsBloc;
  final NavigationService navigationService;
  final LocalStorageService storageService;

  SummaryCubit(this.databaseRepository, this.processingQueueBloc, this.gpsBloc,
      this.storageService, this.navigationService)
      : super(const SummaryLoading());

  Future<void> getAllSummariesByOrderNumber(int workId) async {
    emit(await _getAllSummariesByOrderNumber(workId));
  }

  Future<SummaryState> _getAllSummariesByOrderNumber(int workId) async {
    final summaries =
        await databaseRepository.getAllSummariesByOrderNumber(workId);

    Future.forEach(summaries, (summary) async {
      if (summary.expedition != null) {
        var response = await countBox(summary.orderNumber);
        summary.totalSummary = response[0] as int;
        summary.totalLooseSummary = response[1] as int;
      }
    });

    var time = await databaseRepository.getDiffTime(workId);
    var isArrived =
        await databaseRepository.validateTransactionArrived(workId, 'arrived');
    var isGeoReferenced = await databaseRepository.validateClient(workId);

    return SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: time,
        isArrived: isArrived,
        isGeoReference: isGeoReferenced);
  }

  Future<void> getAllSummariesByOrderNumberChanged(int workId) async {
    emit(const SummaryLoading());

    final summaries =
        await databaseRepository.getAllSummariesByOrderNumber(workId);

    Future.forEach(summaries, (summary) async {
      if (summary.expedition != null) {
        var response = await countBox(summary.orderNumber);
        summary.totalSummary = response[0] as int;
        summary.totalLooseSummary = response[1] as int;
      }
    });

    var time = await databaseRepository.getDiffTime(workId);
    var isArrived =
        await databaseRepository.validateTransactionArrived(workId, 'arrived');
    var isGeoReferenced = await databaseRepository.validateClient(workId);

    emit(SummaryChanged(
        summaries: summaries,
        origin: state.origin,
        time: time,
        isArrived: isArrived,
        isGeoReference: isGeoReferenced));
  }

  Future<List> countBox(String orderNumber) async {
    final summaryFutures = await Future.wait([
      databaseRepository.getTotalPackageSummaries(orderNumber),
      databaseRepository.getTotalPackageSummariesLoose(orderNumber),
    ]);

    return summaryFutures;
  }

  Future<void> getDiffTime(int workId) async {
    var time = await databaseRepository.getDiffTime(workId);
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

    var vts = await databaseRepository.validateTransactionSummary(
        work.workcode!, summary.orderNumber, 'summary');
    var isArrived = await databaseRepository.validateTransactionArrived(
        transaction.workId, 'arrived');

    if (isArrived && vts == false) {
      var currentLocation = gpsBloc.state.lastKnownLocation;
      currentLocation ??= gpsBloc.lastRecordedLocation;

      transaction.latitude = currentLocation!.latitude.toString();
      transaction.longitude = currentLocation.longitude.toString();

      var id = await databaseRepository.insertTransaction(transaction);

      var processingQueue = ProcessingQueue(
          body: jsonEncode(transaction.toJson()),
          task: 'incomplete',
          code: 'store_transaction_summary',
          relation: 'transactions',
          relationId: id.toString(),
          createdAt: now(),
          updatedAt: now());

      processingQueueBloc
          .add(ProcessingQueueAdd(processingQueue: processingQueue));
    }

    final summaries =
        await databaseRepository.getAllSummariesByOrderNumber(work.id!);

    emit(SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: state.time,
        isArrived: isArrived,
        isGeoReference: state.isGeoReference));

    navigationService.goTo(AppRoutes.inventory,
        arguments: InventoryArgument(
            work: work, summary: summary, summaries: summaries));
  }

  bool validateDistance(
      currentLocation, double lat, double log, summaryId, int? ratio) {
    if (storageService.getBool('$summaryId-distance_ignore') != null &&
        storageService.getBool('$summaryId-distance_ignore') == true) {
      return true;
    } else {
      return helperFunctions.isWithinRadiusGeo(
          currentLocation, lat, log, ratio!);
    }
  }

  Future<void> sendTransactionArrived(
      BuildContext context, Work work, Transaction transaction) async {
    emit(const SummaryLoading());

    var currentLocation = gpsBloc.state.lastKnownLocation;

    transaction.latitude = currentLocation!.latitude.toString();
    transaction.longitude = currentLocation.longitude.toString();

    final summaries =
        await databaseRepository.getAllSummariesByOrderNumber(work.id!);

    var isGeoReferenced =
        await databaseRepository.validateClient(transaction.workId);

    final enterpriseConfig = storageService.getObject('config') != null
        ? EnterpriseConfig.fromMap(storageService.getObject('config')!)
        : null;

    logDebug(headerSummaryLogger, enterpriseConfig.toString());

    if (enterpriseConfig != null &&
        enterpriseConfig.fixedDeliveryDistance == true) {
      var distanceInMeters = helperFunctions.calculateDistanceInMetersGeo(
          currentLocation,
          double.tryParse(work.latitude!)!,
          double.tryParse(work.longitude!)!);

      if (!validateDistance(
              currentLocation,
              double.tryParse(work.latitude!)!,
              double.tryParse(work.longitude!)!,
              transaction.summaryId,
              enterpriseConfig.ratio) &&
          context.mounted) {
        helperFunctions.showDialogWithDistance(
            context, distanceInMeters, enterpriseConfig.ratio!);

        emit(SummarySuccess(
            summaries: summaries,
            origin: state.origin,
            time: state.time,
            isArrived: true,
            isGeoReference: isGeoReferenced));
      }
    }

    await databaseRepository.insertTransaction(transaction);

    var processingQueue = ProcessingQueue(
        body: jsonEncode(transaction.toJson()),
        task: 'incomplete',
        code: 'store_transaction_arrived',
        createdAt: now(),
        updatedAt: now());

    processingQueueBloc
        .add(ProcessingQueueAdd(processingQueue: processingQueue));

    emit(SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: state.time,
        isArrived: true,
        isGeoReference: isGeoReferenced));
  }

  Future<void> showMaps(
      BuildContext context,
      SummaryNavigationArgument arguments,
      DirectionsMode directionsMode) async {
    emit(const SummaryLoadingMap());
    var currentLocation = gpsBloc.state.lastKnownLocation;
    if (context.mounted) {
      helperFunctions.showMapDirection(
          context, arguments.work, currentLocation!);
    }

    final summaries = await databaseRepository
        .getAllSummariesByOrderNumber(arguments.work.id!);

    var isArrived = await databaseRepository.validateTransactionArrived(
        arguments.work.id!, 'arrived');

    var isGeoReferenced =
        await databaseRepository.validateClient(arguments.work.id!);

    emit(SummarySuccess(
        summaries: summaries,
        origin: state.origin,
        time: state.time,
        isArrived: isArrived,
        isGeoReference: isGeoReferenced));
  }

  Future<void> error(int id, String error) async {
    final summaries = await databaseRepository.getAllSummariesByOrderNumber(id);

    var isArrived =
        await databaseRepository.validateTransactionArrived(id, 'arrived');

    var isGeoReferenced = await databaseRepository.validateClient(id);

    emit(SummaryFailed(
        error: error,
        summaries: summaries,
        origin: state.origin,
        time: state.time,
        isArrived: isArrived,
        isGeoReference: isGeoReferenced));
  }
}
