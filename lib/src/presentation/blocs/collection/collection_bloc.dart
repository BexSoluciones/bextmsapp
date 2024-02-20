import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
//core
import '../../../../core/helpers/index.dart';
//domain
import '../../../domain/models/arguments.dart';
import '../../../domain/models/payment.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/transaction_summary.dart';
import '../../../domain/models/work.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/enterprise_config.dart';
import '../../../domain/models/payment_account.dart';
import '../../../domain/models/payment_efecty.dart';
import '../../../domain/models/payment_transfer.dart';
import '../../../domain/models/payment_multi_transfer.dart';
import '../../../domain/models/payment_date.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/abstracts/format_abstract.dart';
//blocs
import '../gps/gps_bloc.dart';
import '../processing_queue/processing_queue_bloc.dart';

//services
import '../../../services/navigation.dart';
import '../../../services/storage.dart';

part 'collection_event.dart';
part 'collection_state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState>
    with FormatDate {
  final DatabaseRepository databaseRepository;
  final ProcessingQueueBloc processingQueueBloc;
  final GpsBloc gpsBloc;
  final LocalStorageService storageService;
  final NavigationService navigationService;

  final helperFunctions = HelperFunctions();

  CollectionBloc(this.databaseRepository, this.processingQueueBloc,
      this.gpsBloc, this.storageService, this.navigationService)
      : super(const CollectionState()) {
    on<CollectionLoading>(_getCollection);
    on<CollectionNavigate>(_onNavigate);
    on<CollectionBack>(_onBack);
    on<CollectionPaymentEfectyChanged>(_onPaymentEfectyChanged);
    on<CollectionPaymentEfectyClear>(_onPaymentEfectyClear);
    on<CollectionPaymentTransferChanged>(_onPaymentTransferChanged);
    on<CollectionPaymentTransferClear>(_onPaymentTransferClear);
    on<CollectionPaymentMultiTransferChanged>(_onPaymentMultiTransferChanged);
    on<CollectionPaymentDateChanged>(_onPaymentDateChanged);
    on<CollectionPaymentAccountChanged>(_onPaymentAccountChanged);
    on<CollectionButtonPressed>(_onCollectionButtonPressed);
    on<CollectionConfirmTransaction>(_onConfirmTransaction);
    on<CollectionCloseModal>(_onCloseModal);
    on<CollectionOpenModal>(_onOpenModal);
    on<CollectionAddOrUpdatePayment>(addOrUpdatePaymentWithAccount);
    on<CollectionEditPaymentWithAccount>(editPaymentWithAccount);
    on<CollectionRemovePayment>(_onRemovePayment);
    on<CollectionError>(_onError);
  }

  Future<void> _getCollection(
    CollectionLoading event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CollectionStatus.loading));

      var totalSummary = await databaseRepository.getTotalSummaries(
          event.workId, event.orderNumber);

      print('************');
      print(totalSummary);

      emit(state.copyWith(
          status: CollectionStatus.initial,
          formSubmissionStatus: FormSubmissionStatus.initial,
          date: PaymentDate.create(
              DateFormat('yyyy-MM-dd').format(DateTime.now())),
          accounts: [],
          totalSummary: totalSummary,
          enterpriseConfig: storageService.getObject('config') != null
              ? EnterpriseConfig.fromMap(storageService.getObject('config')!)
              : null));
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
      emit(state.copyWith(
          status: CollectionStatus.error, error: error.toString()));
    }
  }

  Future<void> _onNavigate(
    CollectionNavigate event,
    Emitter<CollectionState> emit,
  ) async {
    emit(state.copyWith(status: CollectionStatus.navigate));
    navigationService.goTo(event.route, arguments: event.arguments);
  }

  Future<void> _onBack(
    CollectionBack event,
    Emitter<CollectionState> emit,
  ) async {
    emit(state.copyWith(status: CollectionStatus.back));
  }

  Future<void> _onCollectionButtonPressed(
    CollectionButtonPressed event,
    Emitter<CollectionState> emit,
  ) async {
    if (!state.isValid) return;
    try {
      emit(state.copyWith(
          formSubmissionStatus: FormSubmissionStatus.submitting));

      if (state.enterpriseConfig != null) {
        final allowInsetsBelow = state.enterpriseConfig!.allowInsetsBelow;
        final allowInsetsAbove = state.enterpriseConfig!.allowInsetsAbove;

        if (state.enterpriseConfig!.multipleAccounts == false &&
            state.enterpriseConfig!.specifiedAccountTransfer == true &&
            state.transfer.value.isNotEmpty &&
            state.account == null) {
          emit(state.copyWith(
              status: CollectionStatus.error,
              error: 'Selecciona un numero de cuenta'));
        }

        if (event.arguments.summary.typeOfCharge == 'CREDITO' &&
            state.total == 0) {
          storageService.setBool('firmRequired', false);
          storageService.setBool('photoRequired', false);
          return add(CollectionConfirmTransaction(arguments: event.arguments));
        }

        if ((allowInsetsBelow == null || allowInsetsBelow == false) &&
            (allowInsetsAbove == null || allowInsetsAbove == false)) {
          if (state.total == state.totalSummary) {
            storageService.setBool('firmRequired', false);
            storageService.setBool('photoRequired', false);
            return add(
                CollectionConfirmTransaction(arguments: event.arguments));
          } else {
            emit(state.copyWith(
              formSubmissionStatus: FormSubmissionStatus.failure,
              error: 'el recaudo debe ser igual al total',
            ));
          }
        } else if ((allowInsetsBelow != null && allowInsetsBelow == true) &&
            (allowInsetsAbove != null && allowInsetsAbove == true)) {
          storageService.setBool('firmRequired', false);
          storageService.setBool('photoRequired', false);
          if (state.total != 0 &&
              state.total <= state.totalSummary.toDouble()) {
            return add(
                CollectionConfirmTransaction(arguments: event.arguments));
          } else {
            emit(state.copyWith(status: CollectionStatus.waiting));
          }
        } else if ((allowInsetsBelow != null && allowInsetsBelow == true) &&
            (allowInsetsAbove == null || allowInsetsAbove == false)) {
          if (state.total <= state.totalSummary.toDouble() &&
              state.total > 0.0) {
            storageService.setBool('firmRequired', false);
            storageService.setBool('photoRequired', false);
            add(CollectionConfirmTransaction(arguments: event.arguments));
            return;
          } else {
            emit(state.copyWith(
                formSubmissionStatus: FormSubmissionStatus.failure,
                error: 'el recaudo debe ser igual o menor al total'));
          }
        } else if ((allowInsetsBelow == null || allowInsetsBelow == false) &&
            (allowInsetsAbove != null && allowInsetsAbove == true)) {
          if (state.total >= state.totalSummary.toDouble()) {
            storageService.setBool('firmRequired', false);
            storageService.setBool('photoRequired', false);
            emit(state.copyWith(status: CollectionStatus.waiting));
          } else {
            emit(state.copyWith(
              formSubmissionStatus: FormSubmissionStatus.failure,
              error: 'el recaudo debe ser igual o mayor al total',
            ));
          }
        }
      } else {
        emit(state.copyWith(status: CollectionStatus.initial));
      }
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
      emit(state.copyWith(
          formSubmissionStatus: FormSubmissionStatus.failure,
          error: error.toString()));
    }
  }

  Future<void> addOrUpdatePaymentWithAccount(
      CollectionAddOrUpdatePayment event, Emitter<CollectionState> emit) async {
    if (event.index != null) {
      state.accounts![event.index!].paid = state.multiTransfer.value;
      state.accounts![event.index!].account = state.account?.value;
      state.accounts![event.index!].date = state.date.value;

      emit(state.copyWith(
        indexToEdit: null,
        isEditing: false,
      ));
    } else {
      if (state.multiTransfer.value.isNotEmpty) {
        if (double.tryParse(state.multiTransfer.value) != null) {
          var transferValue = double.parse(state.multiTransfer.value);

          state.accounts!.add(AccountPayment(
              paid: transferValue.toString(),
              type: 'transfer',
              account: state.account?.value,
              date: state.date.value));

          emit(state.copyWith(accounts: state.accounts));
        }
      }
    }

    double cashValue = 0.0;
    if (state.efecty.value.isNotEmpty) {
      cashValue = double.parse(state.efecty.value);
    }

    var count = 0.0;
    for (var i = 0; i < state.accounts!.length; i++) {
      count += double.parse(state.accounts![i].paid!);
    }

    emit(state.copyWith(
        account: null,
        date: null,
        total: count + cashValue,
        totalSummary: state.totalSummary,
        enterpriseConfig: state.enterpriseConfig));
  }

  Future<void> editPaymentWithAccount(CollectionEditPaymentWithAccount event,
      Emitter<CollectionState> emit) async {
    emit(state.copyWith(
        indexToEdit: event.index,
        isEditing: true,
        totalSummary: state.totalSummary,
        enterpriseConfig: state.enterpriseConfig,
        date: PaymentDate.create(state.accounts![event.index].date!),
        account: PaymentAccount.create(state.accounts![event.index].account),
        multiTransfer:
            PaymentMultiTransfer.create(state.accounts![event.index].paid!)));
  }

  Future<void> _onRemovePayment(
      CollectionRemovePayment event, Emitter<CollectionState> emit) async {
    state.accounts?.remove(event.payment);

    emit(state.copyWith(
      total: state.total - event.value,
      accounts: state.accounts,
      totalSummary: state.totalSummary,
      enterpriseConfig: state.enterpriseConfig,
    ));
  }

  void _onCloseModal(
      CollectionCloseModal event, Emitter<CollectionState> emit) async {
    emit(state.copyWith(
        totalSummary: state.totalSummary,
        enterpriseConfig: state.enterpriseConfig));
  }

  void _onOpenModal(CollectionOpenModal event, Emitter<CollectionState> emit) {
    emit(state.copyWith(
        totalSummary: state.totalSummary,
        enterpriseConfig: state.enterpriseConfig));
  }

  void _onError(CollectionError event, Emitter<CollectionState> emit) async {
    emit(state.copyWith(
        status: CollectionStatus.error,
        totalSummary: state.totalSummary,
        enterpriseConfig: state.enterpriseConfig,
        error: 'Por favor selecciona una cuenta'));
  }

  Future<void> _onConfirmTransaction(
    CollectionConfirmTransaction event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      var status = event.arguments.r != null && event.arguments.r!.isNotEmpty
          ? 'partial'
          : 'delivery';

      var payments = <Payment>[];

      if (state.efecty.value.isNotEmpty) {
        payments.add(Payment(
          method: 'efecty',
          paid: state.efecty.value,
        ));
      }

      if (state.enterpriseConfig != null &&
          state.enterpriseConfig!.multipleAccounts == true &&
          state.accounts!.isNotEmpty) {
        for (var i = 0; i < state.accounts!.length; i++) {
          payments.add(Payment(
              method: 'transfer',
              paid: state.accounts![i].paid!,
              accountId: state.accounts![i].account!.id!.toString(),
              date: state.accounts![i].date));
        }
      } else {
        if (state.transfer.value.isNotEmpty) {
          payments.add(Payment(
              method: 'transfer',
              paid: state.transfer.value,
              accountId: state.enterpriseConfig != null &&
                      state.enterpriseConfig!.specifiedAccountTransfer == true
                  ? state.account!.value?.id.toString()
                  : null,
              date: state.enterpriseConfig != null &&
                      state.enterpriseConfig!.specifiedAccountTransfer == true
                  ? state.date.value
                  : null));
        }
      }

      if (event.arguments.summary.typeOfCharge != 'CREDITO' &&
          payments.isEmpty &&
          (status == 'delivery' || status == 'partial')) {
        emit(state.copyWith(
            formSubmissionStatus: FormSubmissionStatus.failure,
            error:
                'No hay pagos para el recaudo que cumpla con las condiciones.'));
      } else {
        var currentLocation = gpsBloc.state.lastKnownLocation;
        currentLocation ??= gpsBloc.lastRecordedLocation;

        String? firm;
        var firmApplication = await helperFunctions
            .getFirm('firm-${event.arguments.summary.orderNumber}');
        if (firmApplication != null) {
          var base64Firm = firmApplication.readAsBytesSync();
          firm = base64Encode(base64Firm);
        }

        var images = await helperFunctions
            .getImages(event.arguments.summary.orderNumber);

        if (state.enterpriseConfig != null &&
            state.enterpriseConfig!.hadTakePicture == true &&
            images.isEmpty) {
          emit(state.copyWith(
              formSubmissionStatus: FormSubmissionStatus.failure,
              error: 'La foto es obligatoria.'));
        } else {
          var imagesServer = <String>[];
          if (images.isNotEmpty) {
            for (var element in images) {
              List<int> imageBytes = element.readAsBytesSync();
              var base64Image = base64Encode(imageBytes);
              imagesServer.add(base64Image);
            }
          }

          var totalSummary = await databaseRepository.getTotalSummaries(
              event.arguments.work.id!, event.arguments.summary.orderNumber);

          var transaction = Transaction(
              workId: event.arguments.work.id!,
              summaryId: event.arguments.summary.id,
              workcode: event.arguments.work.workcode,
              orderNumber: event.arguments.summary.orderNumber,
              operativeCenter: event.arguments.summary.operativeCenter,
              status: status,
              payments: payments,
              firm: firm,
              images: imagesServer.isNotEmpty ? imagesServer : null,
              delivery: totalSummary.toString(),
              start: now(),
              end: null,
              latitude: currentLocation!.latitude.toString(),
              longitude: currentLocation.longitude.toString());

          var id = await databaseRepository.insertTransaction(transaction);

          var processingQueue = ProcessingQueue(
              body: jsonEncode(transaction.toJson()),
              task: 'incomplete',
              code: 'store_transaction',
              relationId: id.toString(),
              relation: 'transactions',
              createdAt: now(),
              updatedAt: now());

          processingQueueBloc
              .add(ProcessingQueueAdd(processingQueue: processingQueue));

          if (status == 'partial') {
            await Future.forEach(event.arguments.summaries!, (summary) async {
              if (summary.minus != 0) {
                var reason = event.arguments.r!
                    .where((element) => element.summaryId == summary.id)
                    .toList();

                var re = await databaseRepository
                    .findReason(reason[0].controller.text);

                var transactionSummary = TransactionSummary(
                    productName: summary.nameItem,
                    numItems: (summary.minus *
                            double.parse(summary.unitOfMeasurement))
                        .toString(),
                    summaryId: summary.id,
                    orderNumber: summary.orderNumber,
                    workId: event.arguments.work.id!,
                    codmotvis: re!.codmotvis,
                    reason: reason[0].controller.text,
                    createdAt: now(),
                    updatedAt: now());

                var id = await databaseRepository
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

                processingQueueBloc
                    .add(ProcessingQueueAdd(processingQueue: processingQueue));
              }
            });
          }

          await helperFunctions
              .deleteImages(event.arguments.summary.orderNumber);
          await helperFunctions
              .deleteFirm('firm-${event.arguments.summary.orderNumber}');

          var isLastTransaction = await databaseRepository
              .checkLastTransaction(event.arguments.work.workcode!);

          var v = await databaseRepository
              .validateTransaction(event.arguments.work.id!);

          emit(state.copyWith(
              status: CollectionStatus.success,
              formSubmissionStatus: FormSubmissionStatus.success,
              efecty: PaymentEfecty.empty,
              transfer: PaymentTransfer.empty,
              accounts: null,
              account: null,
              validate: v,
              isLastTransaction: isLastTransaction,
              total: 0,
              work: event.arguments.work));
        }
      }
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
      emit(state.copyWith(
          formSubmissionStatus: FormSubmissionStatus.failure,
          error: error.toString()));
    }
  }

  Future<void> _onPaymentEfectyChanged(
    CollectionPaymentEfectyChanged event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      emit(state.copyWith(
          efecty: PaymentEfecty.create(event.value),
          formSubmissionStatus: FormSubmissionStatus.initial));

      if (state.transfer.value.isNotEmpty && state.efecty.value.isNotEmpty) {
        emit(state.copyWith(
          total: double.tryParse(state.efecty.value)! +
              double.tryParse(state.transfer.value)!,
        ));
      } else if (state.efecty.value.isNotEmpty &&
          state.accounts != null &&
          state.accounts!.isNotEmpty) {
        emit(state.copyWith(total: 0));
        var cashValue = double.tryParse(state.efecty.value)!;
        var count = 0.0;
        for (var i = 0; i < state.accounts!.length; i++) {
          count += double.tryParse(state.accounts![i].paid.toString())!;
        }

        emit(state.copyWith(total: count + cashValue));
      } else if (state.efecty.value.isEmpty &&
          state.accounts != null &&
          state.accounts!.isNotEmpty) {
        emit(state.copyWith(total: 0));
        var count = 0.0;
        for (var i = 0; i < state.accounts!.length; i++) {
          count += double.tryParse(state.accounts![i].paid.toString())!;
        }
        emit(state.copyWith(total: count));
      } else if (state.efecty.value.isNotEmpty) {
        emit(state.copyWith(
            total: double.tryParse(state.efecty.value)!,
            efecty: PaymentEfecty.create(event.value),
            formSubmissionStatus: FormSubmissionStatus.initial));
      } else if (state.efecty.value.isEmpty && state.transfer.value.isEmpty) {
        emit(state.copyWith(total: 0));
      } else if (state.transfer.value.isNotEmpty &&
          state.efecty.value.isEmpty) {
        emit(state.copyWith(total: double.tryParse(state.transfer.value)!));
      }
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
    }
  }

  Future<void> _onPaymentEfectyClear(
    CollectionPaymentEfectyClear event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      if (state.efecty.value.isNotEmpty) {
        emit(state.copyWith(
            total: state.total - int.parse(state.efecty.value),
            efecty: PaymentEfecty.empty,
            keyEfecty: state.keyEfecty + 1,
            formSubmissionStatus: FormSubmissionStatus.initial));
      }
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
    }
  }

  Future<void> _onPaymentTransferChanged(
    CollectionPaymentTransferChanged event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      emit(state.copyWith(
          transfer: PaymentTransfer.create(event.value),
          formSubmissionStatus: FormSubmissionStatus.initial));

      if (state.efecty.value.isNotEmpty && state.transfer.value.isNotEmpty) {
        emit(state.copyWith(
            total: double.tryParse(state.transfer.value)! +
                double.tryParse(state.efecty.value)!));
      } else if (state.transfer.value.isNotEmpty) {
        emit(state.copyWith(total: double.tryParse(state.transfer.value)!));
      } else if (state.efecty.value.isEmpty && state.transfer.value.isEmpty) {
        emit(state.copyWith(total: 0));
      } else if (state.efecty.value.isNotEmpty &&
          state.transfer.value.isEmpty) {
        emit(state.copyWith(total: double.tryParse(state.efecty.value)!));
      }
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
    }
  }

  Future<void> _onPaymentTransferClear(
    CollectionPaymentTransferClear event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      if (state.efecty.value.isNotEmpty) {
        emit(state.copyWith(
            total: state.total - int.parse(state.transfer.value),
            transfer: PaymentTransfer.empty,
            keyTransfer: state.keyTransfer + 1,
            formSubmissionStatus: FormSubmissionStatus.initial));
      }
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
    }
  }

  Future<void> _onPaymentDateChanged(
    CollectionPaymentDateChanged event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      emit(state.copyWith(
          date: PaymentDate.create(event.value),
          formSubmissionStatus: FormSubmissionStatus.initial));
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
    }
  }

  Future<void> _onPaymentAccountChanged(
    CollectionPaymentAccountChanged event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      emit(state.copyWith(
          account: PaymentAccount.create(event.value),
          formSubmissionStatus: FormSubmissionStatus.initial));
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
    }
  }

  Future<void> _onPaymentMultiTransferChanged(
    CollectionPaymentMultiTransferChanged event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      emit(state.copyWith(
          multiTransfer: PaymentMultiTransfer.create(event.value),
          formSubmissionStatus: FormSubmissionStatus.initial));
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
    }
  }
}
