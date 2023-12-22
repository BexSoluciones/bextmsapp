import 'dart:async';
import 'dart:convert';
import 'package:bexdeliveries/src/services/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

//core
import '../../../../core/helpers/index.dart';

//utils
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
import '../../../domain/models/account.dart';
import '../../../domain/models/transaction_summary.dart';
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
      : super(const CollectionLoading(), null);

  final TextEditingController transferController = TextEditingController();
  final TextEditingController multiTransferController = TextEditingController();
  final TextEditingController cashController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Account? selectedAccount;
  double total = 0;
  bool isEditing = false;
  int? indexToEdit;
  List<AccountPayment> selectedAccounts = [];

  void listenForCash() {
    try {
      if (transferController.text.isNotEmpty &&
          cashController.text.isNotEmpty) {
        total = double.tryParse(cashController.text)! +
            double.tryParse(transferController.text)!;
      } else if (cashController.text.isNotEmpty &&
          selectedAccounts.isNotEmpty) {
        total = 0;
        var cashValue = double.tryParse(cashController.text)!;
        var count = 0.0;
        for (var i = 0; i < selectedAccounts.length; i++) {
          count += double.tryParse(selectedAccounts[i].paid.toString())!;
        }
        total = count + cashValue;
      } else if (cashController.text.isEmpty && selectedAccounts.isNotEmpty) {
        total = 0;
        for (var i = 0; i < selectedAccounts.length; i++) {
          total += double.tryParse(selectedAccounts[i].paid.toString())!;
        }
      } else if (cashController.text.isNotEmpty) {
        total = double.tryParse(cashController.text)!;
      } else if (cashController.text.isEmpty &&
          transferController.text.isEmpty) {
        total = 0;
      } else if (transferController.text.isNotEmpty &&
          cashController.text.isEmpty) {
        total = double.tryParse(transferController.text)!;
      }
    } catch (e) {
      logDebugFine(headerDeveloperLogger, e.toString());
    }
  }

  void listenForTransfer() {
    try {
      if (!isEditing) {
        if (cashController.text.isNotEmpty &&
            transferController.text.isNotEmpty) {
          total = double.tryParse(transferController.text)! +
              double.tryParse(cashController.text)!;
        } else if (transferController.text.isNotEmpty) {
          total = double.tryParse(transferController.text)!;
        } else if (cashController.text.isEmpty &&
            transferController.text.isEmpty) {
          total = 0;
        } else if (cashController.text.isNotEmpty &&
            transferController.text.isEmpty) {
          total = double.tryParse(cashController.text)!;
        }
      }
    } catch (e) {
      logDebugFine(headerDeveloperLogger, e.toString());
    }
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
    total = 0;
    dateController.text = date(null);
    return CollectionInitial(
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

  void goToCodeQR(String? qr) {
    _navigationService.goTo(AppRoutes.codeQr, arguments: qr);
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

  Future<void> validate(InventoryArgument arguments) async {
    if (isBusy) return;

    await run(() async {
      emit(CollectionLoading(
          totalSummary: state.totalSummary,
          enterpriseConfig: state.enterpriseConfig));

      if (state.enterpriseConfig != null) {
        final allowInsetsBelow = state.enterpriseConfig!.allowInsetsBelow;
        final allowInsetsAbove = state.enterpriseConfig!.allowInsetsAbove;

        if (state.enterpriseConfig!.multipleAccounts == false &&
            state.enterpriseConfig!.specifiedAccountTransfer == true &&
            transferController.text.isNotEmpty &&
            selectedAccount == null) {
          emit(CollectionFailed(
              totalSummary: state.totalSummary,
              enterpriseConfig: state.enterpriseConfig,
              error: 'Selecciona un numero de cuenta'));
        }

        if (arguments.summary.typeOfCharge == 'CREDITO' && total == 0) {
          _storageService.setBool('firmRequired', false);
          _storageService.setBool('photoRequired', false);
          confirmTransaction(arguments);
        }

        if ((allowInsetsBelow == null || allowInsetsBelow == false) &&
            (allowInsetsAbove == null || allowInsetsAbove == false)) {
          if (total == state.totalSummary!.toDouble()) {
            _storageService.setBool('firmRequired', false);
            _storageService.setBool('photoRequired', false);
            confirmTransaction(arguments);
          } else {
            emit(CollectionFailed(
                totalSummary: state.totalSummary,
                enterpriseConfig: state.enterpriseConfig,
                error: 'el recaudo debe ser igual al total'));
          }
        } else if ((allowInsetsBelow != null && allowInsetsBelow == true) &&
            (allowInsetsAbove != null && allowInsetsAbove == true)) {
          _storageService.setBool('firmRequired', false);
          _storageService.setBool('photoRequired', false);

          if (total != 0 && total <= state.totalSummary!.toDouble()) {
            confirmTransaction(arguments);
          } else {
            emit(const CollectionWaiting());
          }
        } else if ((allowInsetsBelow != null && allowInsetsBelow == true) &&
            (allowInsetsAbove == null || allowInsetsAbove == false)) {
          if (total <= state.totalSummary!.toDouble()) {
            _storageService.setBool('firmRequired', false);
            _storageService.setBool('photoRequired', false);
            confirmTransaction(arguments);
          } else {
            emit(CollectionFailed(
                totalSummary: state.totalSummary,
                enterpriseConfig: state.enterpriseConfig,
                error: 'el recaudo debe ser igual o menor al total'));
          }
        } else if ((allowInsetsBelow == null || allowInsetsBelow == false) &&
            (allowInsetsAbove != null && allowInsetsAbove == true)) {
          if (total >= state.totalSummary!.toDouble()) {
            _storageService.setBool('firmRequired', false);
            _storageService.setBool('photoRequired', false);
            emit(const CollectionWaiting());
          } else {
            emit(CollectionFailed(
                totalSummary: state.totalSummary,
                enterpriseConfig: state.enterpriseConfig,
                error: 'el recaudo debe ser igual o mayor al total'));
          }
        }
      } else {
        emit(CollectionInitial(
            totalSummary: state.totalSummary,
            enterpriseConfig: _storageService.getObject('config') != null
                ? EnterpriseConfig.fromMap(_storageService.getObject('config')!)
                : null));
      }
    });
  }

  Future<void> addOrUpdatePaymentWithAccount({int? index}) async {
    if (isBusy) return;

    await run(() async {
      if (index != null) {
        selectedAccounts[index].paid = transferController.text;
        selectedAccounts[index].account = selectedAccount;
        selectedAccounts[index].date = dateController.text;

        indexToEdit = null;
        isEditing = false;
      } else {
        if (multiTransferController.text.isNotEmpty) {
          if (double.tryParse(multiTransferController.text) != null) {
            var transferValue = double.parse(multiTransferController.text);

            selectedAccounts.add(AccountPayment(
                paid: transferValue.toString(),
                type: 'transfer',
                account: selectedAccount,
                date: dateController.text));
          }
        }
      }

      double cashValue = 0.0;
      if (cashController.text.isNotEmpty) {
        cashValue = double.parse(cashController.text);
      }

      var count = 0.0;
      for (var i = 0; i < selectedAccounts.length; i++) {
        count += double.parse(selectedAccounts[i].paid!);
      }

      total = count + cashValue;
      multiTransferController.clear();
      selectedAccount = null;
      dateController.text = date(null);

      emit(CollectionInitial(
          totalSummary: state.totalSummary,
          enterpriseConfig: state.enterpriseConfig));
    });
  }

  Future<void> editPaymentWithAccount(int index) async {
    if (isBusy) return;

    await run(() async {
      indexToEdit = index;
      isEditing = true;

      dateController.text = selectedAccounts[index].date!;
      transferController.text = selectedAccounts[index].paid!;
      selectedAccount = selectedAccounts[index].account;

      emit(CollectionEditingPayment(
          totalSummary: state.totalSummary,
          enterpriseConfig: state.enterpriseConfig));
    });
  }

  void closeModal() async {
    if (isBusy) return;
    await run(() async {
      emit(CollectionModalClosed(
          totalSummary: state.totalSummary,
          enterpriseConfig: state.enterpriseConfig));
    });
  }

  Future<void> confirmTransaction(InventoryArgument arguments) async {
    var status =
        arguments.r != null && arguments.r!.isNotEmpty ? 'partial' : 'delivery';

    var payments = <Payment>[];

    if (cashController.text.isNotEmpty) {
      payments.add(Payment(
        method: 'cash',
        paid: cashController.text,
      ));
    }

    if (state.enterpriseConfig!.multipleAccounts == true &&
        selectedAccounts.isNotEmpty) {
      for (var i = 0; i < selectedAccounts.length; i++) {
        payments.add(Payment(
            method: 'transfer',
            paid: selectedAccounts[i].paid!,
            accountId: selectedAccounts[i].account!.id!.toString(),
            date: selectedAccounts[i].date));
      }
    } else {
      if (transferController.text.isNotEmpty) {
        payments.add(Payment(
            method: 'transfer',
            paid: transferController.text,
            accountId: state.enterpriseConfig!.specifiedAccountTransfer == true
                ? selectedAccount!.id.toString()
                : null,
            date: state.enterpriseConfig!.specifiedAccountTransfer == true
                ? dateController.text
                : null));
      }
    }

    if (payments.isEmpty && (status == 'delivery' || status == 'partial')) {
      emit(CollectionFailed(
          totalSummary: state.totalSummary,
          enterpriseConfig: state.enterpriseConfig,
          error:
              'No hay pagos para el recaudo que cumpla con las condiciones'));
    } else {
      var currentLocation = gpsBloc.state.lastKnownLocation;

      String? firm;
      var firmApplication = await helperFunctions
          .getFirm('firm-${arguments.summary.orderNumber}');
      if (firmApplication != null) {
        var base64Firm = firmApplication.readAsBytesSync();
        firm = base64Encode(base64Firm);
      }

      var images =
          await helperFunctions.getImages(arguments.summary.orderNumber);
      var imagesServer = <String>[];
      if (images.isNotEmpty) {
        for (var element in images) {
          List<int> imageBytes = element.readAsBytesSync();
          var base64Image = base64Encode(imageBytes);
          imagesServer.add(base64Image);
        }
      }

      var totalSummary = await _databaseRepository.getTotalSummaries(
          arguments.work.id!, arguments.summary.orderNumber);

      var transaction = Transaction(
          workId: arguments.work.id!,
          summaryId: arguments.summary.id,
          workcode: arguments.work.workcode,
          orderNumber: arguments.summary.orderNumber,
          operativeCenter: arguments.summary.operativeCenter,
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

            var re =
                await _databaseRepository.findReason(reason[0].controller.text);

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
                createdAt: now(),
                updatedAt: now());

            var id = await _databaseRepository
                .insertTransactionSummary(transactionSummary);

            var processingQueue = ProcessingQueue(
              body: jsonEncode(transactionSummary.toJson()),
              task: 'incomplete',
              code: 'store_transaction_product',
              relationId: id.toString(),
              relation: 'transactions',
              createdAt: now(),
              updatedAt: now(),
            );

            _processingQueueBloc
                .add(ProcessingQueueAdd(processingQueue: processingQueue));
          }
        });
      }

      await helperFunctions.deleteImages(arguments.summary.orderNumber);
      await helperFunctions.deleteFirm('firm-${arguments.summary.orderNumber}');

      var v = await _databaseRepository.validateTransaction(arguments.work.id!);

      cashController.clear();
      transferController.clear();
      selectedAccounts.clear();

      emit(CollectionSuccess(
        work: arguments.work,
        validate: v,
      ));
    }
  }
}
