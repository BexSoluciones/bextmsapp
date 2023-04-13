import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:location_repository/location_repository.dart';

//core
import '../../../../core/helpers/index.dart';

//utils
import '../../../domain/models/transaction_summary.dart';
import '../../../utils/constants/strings.dart';

//base
import '../base/base_cubit.dart';

//blocs
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//domain
import '../../../domain/models/payment.dart';
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
  final LocationRepository _locationRepository;
  final ProcessingQueueBloc _processingQueueBloc;

  final helperFunctions = HelperFunctions();

  CollectionCubit(this._databaseRepository, this._locationRepository,
      this._processingQueueBloc)
      : super(const CollectionLoading(), null);

  Future<void> getCollection(int workId, String orderNumber) async {
    emit(await _getCollection(workId, orderNumber));
  }

  Future<CollectionState> _getCollection(int workId, String orderNumber) async {
    var totalSummary =
        await _databaseRepository.getTotalSummaries(workId, orderNumber);

    return CollectionSuccess(
        totalSummary: totalSummary,
        enterpriseConfig: _storageService.getObject('config') != null
            ? EnterpriseConfig.fromMap(_storageService.getObject('config')!)
            : null);
  }

  void goBack() {
    _navigationService.goBack();
  }

  void goToFirm(String orderNumber) {
    _navigationService.goTo(firmRoute, arguments: orderNumber);
  }

  void goToCamera(String orderNumber) {
    _navigationService.goTo(cameraRoute, arguments: orderNumber);
  }

  void goToCodeQR() {
    _navigationService.goTo(qrRoute);
  }

  Future<void> confirmTransaction(InventoryArgument arguments, paymentEfectyController, paymentTransferController) async {
    print(isBusy);
    if (isBusy) return;

    await run(() async {

      print('paso a crear la transaccion');

      emit(const CollectionLoading());

      var status = arguments.r != null && arguments.r!.isNotEmpty ? 'partial' : 'delivery';

      String? firm;
      var firmApplication = await helperFunctions.getFirm('firm-${arguments.orderNumber}');

      if (firmApplication != null) {
        var base64Firm = firmApplication.readAsBytesSync();
        firm = base64Encode(base64Firm);
      }

      print('1');

      var images = await helperFunctions.getImages(arguments.orderNumber);
      var imagesServer = <String>[];
      if (images.isNotEmpty) {
        for (var element in images) {
          List<int> imageBytes = element.readAsBytesSync();
          var base64Image = base64Encode(imageBytes);
          imagesServer.add(base64Image);
        }
      }

      print('2');

      var totalSummary = await _databaseRepository.getTotalSummaries(arguments.work.id!, arguments.orderNumber);

      var payments = <Payment>[];

      if (paymentEfectyController.text.isNotEmpty) {
        payments.add(Payment(
          method: 'efecty',
          paid: paymentEfectyController.text,
        ));
      }

      if (paymentTransferController.text.isNotEmpty) {
        payments.add(Payment(
          method: 'transfer',
          paid: paymentTransferController.text,
        ));
      }

      if (payments.isEmpty && (status == 'delivery' || status == 'partial')) {
        emit(const CollectionFailed(error: 'No hay pagos para el recaudo que cumpla con las condiciones'));
      } else {

        var currentLocation = await _locationRepository.getCurrentLocation();

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
            end: now(),
            latitude: currentLocation.latitude.toString(),
            longitude: currentLocation.longitude.toString());

        await _databaseRepository.insertTransaction(transaction);

        var processingQueue = ProcessingQueue(
            body: jsonEncode(transaction.toJson()),
            task: 'incomplete',
            code: 'Z8RPOZDTJB',
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

              var re = await _databaseRepository.findReason(reason[0].controller.text);

              var transactionSummary = TransactionSummary(
                  productName: summary.nameItem,
                  numItems: (summary.minus * double.parse(summary.unitOfMeasurement)).toString(),
                  summaryId: summary.id,
                  orderNumber: summary.orderNumber,
                  workId: arguments.work.id!,
                  codmotvis: re!.codmotvis,
                  reason: reason[0].controller.text,
                  createdAt: DateTime.now().toString(),
                  updatedAt: DateTime.now().toString());

              await _databaseRepository.insertTransactionSummary(transactionSummary);

              var processingQueue = ProcessingQueue(
                  body: jsonEncode(transactionSummary.toJson()),
                  task: 'incomplete',
                  code: 'LIALIVNRAA',
                  createdAt: now(),
                  updatedAt: now(),
              );

              _processingQueueBloc.add(ProcessingQueueAdd(processingQueue: processingQueue));
            }
          });
        }

        await helperFunctions.deleteImages(arguments.orderNumber);
        await helperFunctions.deleteFirm('firm-${arguments.orderNumber}');

        var validateTx =
            await _databaseRepository.validateTransaction(arguments.work.id!);

        print('4');

        if (validateTx == false) {
          await _navigationService.goTo(summaryRoute,
              arguments: SummaryArgument(
                work: arguments.work,
              ));
        } else {
          await _navigationService.goTo(workRoute,
              arguments: WorkArgument(
                work: arguments.work,
              ));
        }

        emit(const CollectionSuccess());
      }
    });
  }
}
