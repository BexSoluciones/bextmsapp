import 'dart:async';
import 'dart:convert';
import 'package:bexdeliveries/core/helpers/index.dart';
import 'package:bexdeliveries/src/domain/models/enterprise_config.dart';
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
import '../../../domain/models/reason.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/abstracts/format_abstract.dart';
import '../../../domain/repositories/database_repository.dart';

//service
import '../../../services/navigation.dart';
import '../../../services/storage.dart';

part 'respawn_state.dart';

class RespawnCubit extends Cubit<RespawnState> with FormatDate {
  final DatabaseRepository databaseRepository;
  final ProcessingQueueBloc processingQueueBloc;
  final GpsBloc gpsBloc;
  final helperFunctions = HelperFunctions();
  final NavigationService navigationService;
  final LocalStorageService storageService;

  RespawnCubit(this.databaseRepository, this.processingQueueBloc, this.gpsBloc,
      this.storageService, this.navigationService)
      : super(const RespawnLoading());

  Future<void> getReasons() async {
    emit(await _getReasons());
  }

  Future<RespawnState> _getReasons() async {
    var enterpriseConfig = storageService.getObject('config') != null
        ? EnterpriseConfig.fromMap(storageService.getObject('config')!)
        : null;

    List<Reason> reasons = [];

    if (enterpriseConfig != null && enterpriseConfig.hadReasonRespawn == true) {
      reasons = await databaseRepository.getAllReasons();
    }

    return RespawnSuccess(reasons: reasons, enterpriseConfig: enterpriseConfig);
  }

  Future<void> confirmTransaction(InventoryArgument arguments,
      String? nameReason, String observation) async {
    emit(const RespawnLoading());
    final rea = await databaseRepository.findReason(nameReason.toString());
    var enterpriseConfig = storageService.getObject('config') != null
        ? EnterpriseConfig.fromMap(storageService.getObject('config')!)
        : null;

    List<Reason> reasons = [];
    Reason? reason;
    String  firm = '';
    var imagesServer = <String>[];

    if (enterpriseConfig != null && enterpriseConfig.hadReasonRespawn == true) {
      reasons = await databaseRepository.getAllReasons();

      if (nameReason == null) {
        emit(RespawnFailed(
            reasons: reasons,
            enterpriseConfig: enterpriseConfig,
            error: 'El motivo de rechazo no puede estar vacio'));
        return;
      }

      reason = await databaseRepository.findReason(nameReason);

      if (reason == null) {
        emit(RespawnFailed(
            reasons: reasons,
            enterpriseConfig: enterpriseConfig,
            error: 'No se encuentra el motivo seleccionado'));
        return;
      }
    }

    var firmApplication = await helperFunctions
        .getFirm('firm-${arguments.summary.orderNumber}');
    if (firmApplication != null) {
      var base64Firm = firmApplication.readAsBytesSync();
      firm = base64Encode(base64Firm);
    }
    var images = await helperFunctions
        .getImages(arguments.summary.orderNumber);


    if (rea!.photo == 1 && images.isEmpty) {
      emit(RespawnFailed(
        reasons: reasons,
        error:
        'La foto es obligatoria.',
      ));
      return;
    }
    if(rea.firm == 1 && firm == '') {
      emit( RespawnFailed(
        reasons: reasons,
        error:
        'La firma es obligatoria.',
      ));
      return;
    }
    if(rea.observation == 1 && observation ==''){
      emit( RespawnFailed(
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
      status: 'respawn',
      firm: firm,
      images: imagesServer.isNotEmpty ? imagesServer : null,
      codmotvis: reason?.codmotvis,
      reason: reason?.nommotvis,
      observation: observation,
      start: now(),
      end: null,
    );

    var currentLocation = gpsBloc.state.lastKnownLocation;
    currentLocation ??= gpsBloc.lastRecordedLocation;
    currentLocation ??= await gpsBloc.getCurrentLocation();

    if (currentLocation == null) {
      emit(RespawnFailed(
        enterpriseConfig: enterpriseConfig,
        error:
            'Error obteniendo tu ubicación, por favor revisa tu señal y intentalo de nuevo.',
      ));
      return;
    }

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
    await helperFunctions
        .deleteImages(arguments.summary.orderNumber);
    await helperFunctions
        .deleteFirmById('');

    var isLastTransaction =
        await databaseRepository.checkLastTransaction(arguments.work.workcode!);

    emit(RespawnSuccess(reasons: reasons, enterpriseConfig: enterpriseConfig));

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
