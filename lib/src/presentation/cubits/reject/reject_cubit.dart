import 'dart:async';
import 'dart:convert';
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
      String? nameReason, String? observation) async {
    emit(const RejectLoading());
    final reasons = await databaseRepository.getAllReasons();

    if (nameReason == null) {
      emit(RejectFailed(
          reasons: reasons,
          error: 'El motivo de rechazo no puede estar vacio'));
    } else {
      final reason = await databaseRepository.findReason(nameReason);

      if (reason == null) {
        emit(RejectFailed(
            reasons: reasons, error: 'No se encuentra el motivo seleccionado'));
      } else {
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
            start: now(),
            end: now(),
            latitude: null,
            longitude: null);

        var currentLocation = gpsBloc.state.lastKnownLocation;
        currentLocation ??= gpsBloc.lastRecordedLocation;

        transaction.latitude = currentLocation!.latitude.toString();
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

        emit(RejectSuccess(reasons: reasons));

        if (validate == false) {
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
