import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

//core
import '../../../../core/helpers/index.dart';

//utils
import '../../../utils/constants/strings.dart';

//domain
import '../../../domain/models/summary.dart';
import '../../../domain/models/arguments.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/models/enterprise_config.dart';
import '../../../domain/abstracts/format_abstract.dart';

//service
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> with FormatDate {
  final DatabaseRepository databaseRepository;
  final LocalStorageService storageService;
  final NavigationService navigationService;

  final helperFunctions = HelperFunctions();

  InventoryCubit(this.databaseRepository, this.storageService, this.navigationService) : super(const InventoryLoading());

  Future<void> getAllInventoryByOrderNumber(
      int validate, int workId, String orderNumber) async {
    emit(await _getAllInventoryByOrderNumber(validate, workId, orderNumber));
  }

  Future<InventoryState> _getAllInventoryByOrderNumber(
      int validate, int workId, String orderNumber) async {
    var summaries = <Summary>[];
    if (validate == 1) {
      summaries = await databaseRepository.getAllInventoryByPackage(
          workId, orderNumber);
    } else {
      summaries = await databaseRepository.getAllInventoryByOrderNumber(
          workId, orderNumber);
    }

    var totalSummaries =
        await databaseRepository.getTotalSummaries(workId, orderNumber);

    final isArrived =
        await databaseRepository.validateTransactionArrived(workId, 'arrived');

    final isPartial = summaries.where((element) => element.minus > 0);
    final isRejected = summaries.where((element) => element.cant != 0);

    return InventorySuccess(
        summaries: summaries,
        totalSummaries: totalSummaries,
        isArrived: isArrived,
        isPartial: isPartial.isNotEmpty,
        isRejected: isRejected.isEmpty,
        enterpriseConfig: storageService.getObject('config') != null
            ? EnterpriseConfig.fromMap(storageService.getObject('config')!)
            : null);
  }

  Future<void> reset(int validate, int workId, String orderNumber) async {
    await databaseRepository.resetCantSummaries(workId, orderNumber);
    emit(await _getAllInventoryByOrderNumber(validate, workId, orderNumber));
  }

  Future<void> minus(Summary summary, int validate, int workId, String orderNumber) async {
    if (summary.cant > 0) {
      summary.minus++;
      summary.cant--;
      summary.grandTotal = summary.price *
          (summary.cant * double.parse(summary.unitOfMeasurement));
    }
    await databaseRepository.updateSummary(summary);
    emit(await _getAllInventoryByOrderNumber(validate, workId, orderNumber));
  }

  Future<void> longMinus(
      Summary summary, int validate, int workId, String orderNumber) async {
    if (summary.cant > 0) {
      summary.minus = double.parse(summary.amount) ~/
          double.parse(summary.unitOfMeasurement);
      summary.cant = 0.0;
      summary.grandTotal = summary.price *
          (summary.cant * double.parse(summary.unitOfMeasurement));
    }
    await databaseRepository.updateSummary(summary);
    emit(await _getAllInventoryByOrderNumber(validate, workId, orderNumber));
  }

  Future<void> increment(
      Summary summary, int validate, int workId, String orderNumber) async {
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
    await databaseRepository.updateSummary(summary);
    emit(await _getAllInventoryByOrderNumber(validate, workId, orderNumber));
  }

  Future<void> longIncrement(
      Summary summary, int validate, int workId, String orderNumber) async {
    if (summary.cant <=
        (double.parse(summary.amount) /
            double.parse(summary.unitOfMeasurement))) {
      summary.minus = 0;
      summary.cant = double.parse(summary.amount) /
          double.parse(summary.unitOfMeasurement);
      summary.grandTotal = summary.price *
          (summary.cant * double.parse(summary.unitOfMeasurement));
    }
    await databaseRepository.updateSummary(summary);
    emit(await _getAllInventoryByOrderNumber(validate, workId, orderNumber));
  }

  void goToPackage(PackageArgument argument) =>
      navigationService.goTo(AppRoutes.package, arguments: argument);
}
