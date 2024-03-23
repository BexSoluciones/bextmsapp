import 'dart:async';
import 'dart:convert';
import 'package:bexdeliveries/core/helpers/index.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

//blocs
import '../../blocs/gps/gps_bloc.dart';
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//utils
import '../../../utils/constants/strings.dart';

//domain
import '../../../domain/models/processing_queue.dart';
import '../../../domain/models/arguments.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/reason.dart';
import '../../../domain/abstracts/format_abstract.dart';
import '../../../domain/repositories/database_repository.dart';

//service
import '../../../services/navigation.dart';

part 'reject_state.dart';

class RejectCubit extends Cubit<RejectState> with FormatDate {
  final DatabaseRepository databaseRepository;
  final ProcessingQueueBloc processingQueueBloc;
  final GpsBloc gpsBloc;
  final helperFunctions = HelperFunctions();
  final NavigationService navigationService;

  RejectCubit(this.databaseRepository, this.processingQueueBloc, this.gpsBloc,
      this.navigationService)
      : super(const RejectLoading());

  Future<void> getReasons() async {
    emit(await _getReasons());
  }

  Future<RejectState> _getReasons() async {
    final reasons = await databaseRepository.getAllReasons();
    return RejectSuccess(reasons: reasons);
  }

  Future<void> confirmTransaction(InventoryArgument arguments,
      String? nameReason, String observation) async {
    emit(const RejectLoading());
    final reasons = await databaseRepository.getAllReasons();
    final reason = await databaseRepository.findReason(nameReason.toString());
    String  firm = '';
    var imagesServer = <String>[];

    if (nameReason == null) {
      emit(RejectFailed(
          reasons: reasons,
          error: 'El motivo de rechazo no puede estar vacio'));
    } else {

      if (reason == null) {
        emit(RejectFailed(
            reasons: reasons, error: 'No se encuentra el motivo seleccionado'));
      } else {

        var firmApplication = await helperFunctions
            .getFirm('firm-${arguments.summary.orderNumber}');
        if (firmApplication != null) {
          var base64Firm = firmApplication.readAsBytesSync();
          firm = base64Encode(base64Firm);
        }
        var images = await helperFunctions
            .getImages(arguments.summary.orderNumber);


        if (reason.photo == 1 && images.isEmpty) {
          emit(RejectFailed(
            reasons: reasons,
            error:
            'La foto es obligatoria.',
          ));
          return;
        }
        if(reason.firm == 1 && firm == '') {
          emit( RejectFailed(
            reasons: reasons,
            error:
            'La firma es obligatoria.',
          ));
          return;
        }
        if(reason.observation == 1 && observation ==''){
          emit( RejectFailed(
            reasons: reasons,
            error:
            'La observacion es obligatoria.',
          ));
          return;
        }

        if (images.isNotEmpty) {
          for (var element in images) {
            List<int> imageBytes = element.readAsBytesSync();
            var base64Image = base64Encode(imageBytes);
            imagesServer.add(base64Image);
          }
        }

        var transaction = Transaction(
            workId: arguments.work.id!,
            summaryId: arguments.summary.id,
            workcode: arguments.work.workcode,
            orderNumber: arguments.summary.orderNumber,
            operativeCenter: arguments.summary.operativeCenter,
            delivery: arguments.total.toString(),
            status: 'reject',
            codmotvis: reason.codmotvis,
            reason: reason.nommotvis,
            observation: observation,
            firm: firm,
            images: imagesServer.isNotEmpty ? imagesServer : null,
            start: now(),
            end: now(),
            latitude: null,
            longitude: null);

        var currentLocation = gpsBloc.state.lastKnownLocation;
        currentLocation ??= gpsBloc.lastRecordedLocation;
        currentLocation ??= await gpsBloc.getCurrentLocation();

        if (currentLocation == null) {
          emit(const RejectFailed(
            error:
            'Error obteniendo tu ubicación, por favor revisa tu señal y intentalo de nuevo.',
          ));
          return;
        }

        transaction.latitude = currentLocation.latitude.toString();
        transaction.longitude = currentLocation.longitude.toString();

        await databaseRepository.insertTransaction(transaction);

        var processingQueue = ProcessingQueue(
            body: jsonEncode(transaction.toJson()),
            task: 'incomplete',
            code: 'store_transaction',
            createdAt: now(),
            updatedAt: now());

        processingQueueBloc
            .add(ProcessingQueueAdd(processingQueue: processingQueue));

        var validate =
        await databaseRepository.validateTransaction(arguments.work.id!);

        await helperFunctions
            .deleteImages(arguments.summary.orderNumber);
        await helperFunctions
            .deleteFirmById('');


        var isLastTransaction = await databaseRepository
            .checkLastTransaction(arguments.work.workcode!);

        emit(RejectSuccess(reasons: reasons));

        if (isLastTransaction == true) {
          await navigationService.goTo(AppRoutes.home, arguments: 'collection');
        } else if (validate == false) {
          await navigationService.goTo(AppRoutes.summary,
              arguments: SummaryArgument(work: arguments.work));
        } else {
          await navigationService.goTo(AppRoutes.work,
              arguments: WorkArgument(work: arguments.work));
        }
      }
    }
  }
}
