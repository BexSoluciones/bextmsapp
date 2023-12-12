import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

//core
import '../../../../core/helpers/index.dart';

//utils
import '../../../domain/models/transaction_summary.dart';
import '../../../utils/constants/strings.dart';

//base
import '../base/base_cubit.dart';

//blocs
import '../../blocs/processing_queue/processing_queue_bloc.dart';
import '../../blocs/gps/gps_bloc.dart';

//domain
import '../../../domain/models/payment.dart';
import '../../../domain/models/work.dart';
import '../../../domain/models/arguments.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/models/enterprise_config.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/abstracts/format_abstract.dart';

//services
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'collection_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();

class CollectionCubit extends BaseCubit<CollectionState, String?>
    with FormatDate {
  final DatabaseRepository _databaseRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final GpsBloc gpsBloc;

  final helperFunctions = HelperFunctions();

  CollectionCubit(
      this._databaseRepository, this._processingQueueBloc, this.gpsBloc)
      : super(CollectionLoading(), null);

  final TextEditingController transferController = TextEditingController();
  final TextEditingController cashController = TextEditingController();

  late int? accountId;

  void listenForCash() {
    if (transferController.text.isNotEmpty && cashController.text.isNotEmpty) {
      state.total = double.parse(cashController.text) +
          double.parse(transferController.text);
    } else if (cashController.text.isNotEmpty) {
      state.total = double.parse(cashController.text);
    } else if (cashController.text.isEmpty && transferController.text.isEmpty) {
      state.total = 0;
    } else if (transferController.text.isNotEmpty &&
        cashController.text.isEmpty) {
      state.total = double.parse(transferController.text);
    }

    emit(state.copyWith(total: state.total));
  }

  void listenForTransfer() {
    if (cashController.text.isNotEmpty && transferController.text.isNotEmpty) {
      state.total = double.parse(transferController.text) +
          double.parse(cashController.text);
    } else if (transferController.text.isNotEmpty) {
      state.total = double.parse(transferController.text);
    } else if (cashController.text.isEmpty && transferController.text.isEmpty) {
      state.total = 0;
    } else if (cashController.text.isNotEmpty &&
        transferController.text.isEmpty) {
      state.total = double.parse(cashController.text);
    }

    emit(state.copyWith(total: state.total));
  }

  void dispose() {
    cashController.dispose();
    transferController.dispose();
  }

  Future<void> getCollection(int workId, String orderNumber) async {
    emit(await _getCollection(workId, orderNumber));
  }

  Future<CollectionState> _getCollection(int workId, String orderNumber) async {
    var totalSummary =
        await _databaseRepository.getTotalSummaries(workId, orderNumber);

    return CollectionInitial(
        total: 0,
        totalSummary: totalSummary,
        enterpriseConfig: _storageService.getObject('config') != null
            ? EnterpriseConfig.fromMap(_storageService.getObject('config')!)
            : null);
  }

  void goBack() {
    if (state is CollectionSuccess) {
      if (state.validate != null && state.validate == true) {
        goToWork(state.work);
      } else {
        goToSummary(state.work);
      }
    } else {
      _navigationService.goBack();
    }
  }

  void goToFirm(String orderNumber) {
    _navigationService.goTo(AppRoutes.firm, arguments: orderNumber);
  }

  void goToCamera(String orderNumber) {
    _navigationService.goTo(AppRoutes.camera, arguments: orderNumber);
  }

  void goToCodeQR() {
    _navigationService.goTo(AppRoutes.codeQr);
  }

  void goToSummary(work) {
    _navigationService.goTo(AppRoutes.summary,
        arguments: SummaryArgument(
          work: work,
        ));
  }

  void goToWork(work) {
    _navigationService.goTo(AppRoutes.work,
        arguments: WorkArgument(
          work: work,
        ));
  }

  Future<void> validate() async {
    if (isBusy) return;

    await run(() async {
      emit(CollectionLoading());

      final allowInsetsBelow = state.enterpriseConfig!.allowInsetsBelow;
      final allowInsetsAbove = state.enterpriseConfig!.allowInsetsAbove;

      if (state.enterpriseConfig!.specifiedAccountTransfer == true &&
          transferController.text.isNotEmpty) {
        if (accountId == null) {
          emit(CollectionFailed(error: 'Selecciona un numero de cuenta'));
        }
      }

      if ((allowInsetsBelow == null || allowInsetsBelow == false) &&
          (allowInsetsAbove == null || allowInsetsAbove == false)) {
        if (state.total == state.totalSummary!.toDouble()) {
          _storageService.setBool('firmRequired', false);
          _storageService.setBool('photoRequired', false);
          //TODO:: [Heider Zapa] confirm transaction
          //confirmTransaction(arguments, cashController, transferController, data);
        } else {
          emit(CollectionFailed(error: 'el recaudo debe ser igual al total'));
        }
      } else if ((allowInsetsBelow != null && allowInsetsBelow == true) &&
          (allowInsetsAbove != null && allowInsetsAbove == true)) {
        _storageService.setBool('firmRequired', false);
        _storageService.setBool('photoRequired', false);

        if (state.total != null &&
            state.total! <= state.totalSummary!.toDouble()) {
          //TODO:: [Heider Zapa] confirm transaction
        } else {
          //TODO:: [Heider Zapa] show dialog
          // await showDialog(
          //     context: context,
          //     builder: (_) {
          //       return MyDialog(
          //         total: total,
          //         totalSummary:
          //         state.totalSummary!.toDouble(),
          //         confirmateTransaction: () => context
          //             .read<CollectionCubit>()
          //             .confirmTransaction(
          //             widget.arguments,
          //             cashController,
          //             transferController,
          //             data),
          //         context: context,
          //       );
          //     });
        }

        return;
      } else if ((allowInsetsBelow != null && allowInsetsBelow == true) &&
          (allowInsetsAbove == null || allowInsetsAbove == false)) {
        if (state.total != null &&
            state.total! <= state.totalSummary!.toDouble()) {
          _storageService.setBool('firmRequired', false);
          _storageService.setBool('photoRequired', false);
          //TODO:: [Heider Zapa] confirm transaction
        } else {
          emit(CollectionFailed(
              error: 'el recaudo debe ser igual o menor al total'));
        }
        return;
      } else if ((allowInsetsBelow == null || allowInsetsBelow == false) &&
          (allowInsetsAbove != null && allowInsetsAbove == true)) {
        if (state.total != null &&
            state.total! >= state.totalSummary!.toDouble()) {
          _storageService.setBool('firmRequired', false);
          _storageService.setBool('photoRequired', false);
          //TODO:: [Heider Zapa] show dialog
          // await showDialog(
          //     context: context,
          //     builder: (_) {
          //       return MyDialog(
          //         total: total,
          //         totalSummary:
          //         state.totalSummary!.toDouble(),
          //         confirmateTransaction: () => context
          //             .read<CollectionCubit>()
          //             .confirmTransaction(
          //             widget.arguments,
          //             cashController,
          //             transferController,
          //             data),
          //         context: context,
          //       );
          //     });
        } else {
          emit(CollectionFailed(
              error: 'el recaudo debe ser igual o mayor al total'));
        }
      }
    });
  }

  Future<void> confirmTransaction(InventoryArgument arguments, cashController,
      transferController, List<dynamic> data) async {
    if (isBusy) return;

    await run(() async {
      emit(CollectionLoading());

      var status = arguments.r != null && arguments.r!.isNotEmpty
          ? 'partial'
          : 'delivery';

      String? firm;
      var firmApplication =
          await helperFunctions.getFirm('firm-${arguments.orderNumber}');
      if (firmApplication != null) {
        var base64Firm = firmApplication.readAsBytesSync();
        firm = base64Encode(base64Firm);
      }

      var images = await helperFunctions.getImages(arguments.orderNumber);
      var imagesServer = <String>[];
      if (images.isNotEmpty) {
        for (var element in images) {
          List<int> imageBytes = element.readAsBytesSync();
          var base64Image = base64Encode(imageBytes);
          imagesServer.add(base64Image);
        }
      }

      var totalSummary = await _databaseRepository.getTotalSummaries(
          arguments.work.id!, arguments.orderNumber);

      var payments = <Payment>[];
      if (data.isEmpty) {
        if (cashController.text.isNotEmpty) {
          payments.add(Payment(
            method: 'cash',
            paid: cashController.text,
          ));
        }
      }

      for (var i = 0; i < data.length; i++) {
        payments.add(Payment(
            method: 'transfer $i',
            paid: data[i][0].toString(),
            accountId: data[i][1].toString()));
      }

      if (transferController.text.isNotEmpty) {
        payments.add(Payment(
          method: 'transfer',
          paid: transferController.text,
        ));
      }

      if (payments.isEmpty && (status == 'delivery' || status == 'partial')) {
        emit(CollectionFailed(
            error:
                'No hay pagos para el recaudo que cumpla con las condiciones'));
      } else {
        var currentLocation = gpsBloc.state.lastKnownLocation;
        var transaction = Transaction(
            workId: arguments.work.id!,
            summaryId: arguments.summaryId,
            workcode: arguments.work.workcode,
            orderNumber: arguments.orderNumber,
            operativeCenter: arguments.operativeCenter,
            status: status,
            payments: payments,
            firm: firm,
            images: imagesServer.isNotEmpty ? imagesServer : null,
            delivery: totalSummary.toString(),
            start: now(),
            end: null,
            latitude: currentLocation!.latitude.toString(),
            longitude: currentLocation.longitude.toString());

        var id = await _databaseRepository.insertTransaction(transaction);

        var processingQueue = ProcessingQueue(
            body: jsonEncode(transaction.toJson()),
            task: 'incomplete',
            code: 'store_transaction',
            relationId: id.toString(),
            relation: 'transactions',
            createdAt: now(),
            updatedAt: now());

        _processingQueueBloc
            .add(ProcessingQueueAdd(processingQueue: processingQueue));

        if (status == 'partial') {
          await Future.forEach(arguments.summaries!, (summary) async {
            if (summary.minus != 0) {
              var reason = arguments.r!
                  .where((element) => element.summaryId == summary.id)
                  .toList();

              var re = await _databaseRepository
                  .findReason(reason[0].controller.text);

              var transactionSummary = TransactionSummary(
                  productName: summary.nameItem,
                  numItems:
                      (summary.minus * double.parse(summary.unitOfMeasurement))
                          .toString(),
                  summaryId: summary.id,
                  orderNumber: summary.orderNumber,
                  workId: arguments.work.id!,
                  codmotvis: re!.codmotvis,
                  reason: reason[0].controller.text,
                  createdAt: DateTime.now().toString(),
                  updatedAt: DateTime.now().toString());

              var id = await _databaseRepository
                  .insertTransactionSummary(transactionSummary);

              var processingQueue = ProcessingQueue(
                body: jsonEncode(transactionSummary.toJson()),
                task: 'incomplete',
                code: 'store_transaction_product',
                relationId: id.toString(),
                relation: 'transaction_summaries',
                createdAt: now(),
                updatedAt: now(),
              );

              _processingQueueBloc
                  .add(ProcessingQueueAdd(processingQueue: processingQueue));
            }
          });
        }

        await helperFunctions.deleteImages(arguments.orderNumber);
        await helperFunctions.deleteFirm('firm-${arguments.orderNumber}');

        var v =
            await _databaseRepository.validateTransaction(arguments.work.id!);

        emit(CollectionSuccess(
          work: arguments.work,
          validate: v,
        ));
      }
    });
  }
}
