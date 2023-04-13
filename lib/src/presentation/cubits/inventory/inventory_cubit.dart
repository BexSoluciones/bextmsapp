import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_repository/location_repository.dart';

//core
import '../../../../core/helpers/index.dart';

//bloc
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//domain
import '../../../domain/models/summary.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/models/enterprise_config.dart';
import '../../../domain/abstracts/format_abstract.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'inventory_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();

class InventoryCubit extends Cubit<InventoryState> with FormatDate {
  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;
  final ProcessingQueueBloc _processingQueueBloc;

  final helperFunctions = HelperFunctions();

  InventoryCubit(this._databaseRepository, this._locationRepository,
      this._processingQueueBloc)
      : super(const InventoryLoading());

  Future<void> getAllInventoryByOrderNumber(
      int workId, String orderNumber) async {
    emit(await _getAllInventoryByOrderNumber(workId, orderNumber));
  }

  Future<InventoryState> _getAllInventoryByOrderNumber(int workId, String orderNumber) async {
    final summaries = await _databaseRepository.getAllInventoryByOrderNumber(
        workId, orderNumber);

    var totalSummaries =
        await _databaseRepository.getTotalSummaries(workId, orderNumber);

    final isArrived =
        await _databaseRepository.validateTransactionArrived(workId, 'arrived');

    final isPartial = summaries.where((element) => element.minus > 0);
    final isRejected = summaries.where((element) => element.cant != 0);

    return InventorySuccess(
        summaries: summaries,
        totalSummaries: totalSummaries,
        isArrived: isArrived,
        isPartial: isPartial.isNotEmpty,
        isRejected: isRejected.isEmpty,
        enterpriseConfig: _storageService.getObject('config') != null
            ? EnterpriseConfig.fromMap(_storageService.getObject('config')!)
            : null);
  }

  Future<void> reset(int workId, String orderNumber) async {
    await _databaseRepository.resetCantSummaries(workId, orderNumber);
    emit(await _getAllInventoryByOrderNumber(workId, orderNumber));
  }

  Future<void> minus(Summary summary, int workId, String orderNumber) async {
    if (summary.cant > 0) {
      summary.minus++;
      summary.cant--;
      summary.grandTotal = summary.price *
          (summary.cant * double.parse(summary.unitOfMeasurement));
    }
    await _databaseRepository.updateSummary(summary);
    emit(await _getAllInventoryByOrderNumber(workId, orderNumber));
  }

  Future<void> longMinus(
      Summary summary, int workId, String orderNumber) async {
    if (summary.cant > 0) {
      summary.minus = double.parse(summary.amount) ~/
          double.parse(summary.unitOfMeasurement);
      summary.cant = 0.0;
      summary.grandTotal = summary.price *
          (summary.cant * double.parse(summary.unitOfMeasurement));
    }
    await _databaseRepository.updateSummary(summary);
    emit(await _getAllInventoryByOrderNumber(workId, orderNumber));
  }

  Future<void> increment(
      Summary summary, int workId, String orderNumber) async {
    if (summary.cant <
        (double.parse(summary.amount) /
            double.parse(summary.unitOfMeasurement))) {
      if (summary.cant == double.parse(summary.amount)) {
        summary.minus = 0;
      } else {
        summary.minus--;
      }
      summary.cant++;
      summary.grandTotal = summary.price *
          (summary.cant * double.parse(summary.unitOfMeasurement));
    }
    await _databaseRepository.updateSummary(summary);
    emit(await _getAllInventoryByOrderNumber(workId, orderNumber));
  }

  Future<void> longIncrement(
      Summary summary, int workId, String orderNumber) async {
    if (summary.cant <=
        (double.parse(summary.amount) /
            double.parse(summary.unitOfMeasurement))) {
      summary.minus = 0;
      summary.cant = double.parse(summary.amount) /
          double.parse(summary.unitOfMeasurement);
      summary.grandTotal = summary.price *
          (summary.cant * double.parse(summary.unitOfMeasurement));
    }
    await _databaseRepository.updateSummary(summary);
    emit(await _getAllInventoryByOrderNumber(workId, orderNumber));
  }

}
