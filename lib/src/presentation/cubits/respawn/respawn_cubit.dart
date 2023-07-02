import 'dart:async';
import 'dart:convert';
import 'package:bexdeliveries/src/domain/models/enterprise_config.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_repository/location_repository.dart';

//blocs
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
import '../../../locator.dart';
import '../../../services/navigation.dart';
import '../../../services/storage.dart';

part 'respawn_state.dart';

final NavigationService _navigationService = locator<NavigationService>();
final LocalStorageService _storageService = locator<LocalStorageService>();

class RespawnCubit extends Cubit<RespawnState> with FormatDate {
  final DatabaseRepository _databaseRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final LocationRepository _locationRepository;

  CurrentUserLocationEntity? currentLocation;

  RespawnCubit(this._databaseRepository, this._locationRepository,
      this._processingQueueBloc)
      : super(const RespawnLoading());

  Future<void> getReasons() async {
    emit(await _getReasons());
  }

  Future<RespawnState> _getReasons() async {
    var enterpriseConfig = _storageService.getObject('config') != null
        ? EnterpriseConfig.fromMap(_storageService.getObject('config')!)
        : null;

    List<Reason> reasons = [];

    if (enterpriseConfig != null && enterpriseConfig.hadReasonRespawn == true) {
      reasons = await _databaseRepository.getAllReasons();
    }

    return RespawnSuccess(reasons: reasons, enterpriseConfig: enterpriseConfig);
  }

  Future<void> confirmTransaction(InventoryArgument arguments,
      String? nameReason, String? observation) async {
    emit(const RespawnLoading());

    var enterpriseConfig = _storageService.getObject('config') != null
        ? EnterpriseConfig.fromMap(_storageService.getObject('config')!)
        : null;

    List<Reason> reasons = [];
    Reason? reason;

    if (enterpriseConfig != null && enterpriseConfig.hadReasonRespawn == true) {
      reasons = await _databaseRepository.getAllReasons();

      if (nameReason == null) {
        emit(RespawnFailed(
            reasons: reasons,
            enterpriseConfig: enterpriseConfig,
            error: 'El motivo de rechazo no puede estar vacio'));
        return;
      }

      reason = await _databaseRepository.findReason(nameReason);

      if (reason == null) {
        emit(RespawnFailed(
            reasons: reasons,
            enterpriseConfig: enterpriseConfig,
            error: 'No se encuentra el motivo seleccionado'));
        return;
      }
    }

    var transaction = Transaction(
      workId: arguments.work.id!,
      summaryId: arguments.summaryId,
      workcode: arguments.work.workcode,
      orderNumber: arguments.orderNumber,
      operativeCenter: arguments.operativeCenter,
      delivery: arguments.total.toString(),
      status: 'respawn',
      codmotvis: reason?.codmotvis,
      reason: reason?.nommotvis,
      observation: observation,
    );

    currentLocation = await _locationRepository.getCurrentLocation();

    transaction.latitude = currentLocation!.latitude.toString();
    transaction.longitude = currentLocation!.longitude.toString();

    await _databaseRepository.insertTransaction(transaction);

    var processingQueue = ProcessingQueue(
        body: jsonEncode(transaction.toJson()),
        task: 'incomplete',
        code: 'Z8RPOZDTJB',
        createdAt: now(),
        updatedAt: now());

    _processingQueueBloc
        .add(ProcessingQueueAdd(processingQueue: processingQueue));

    var validate =
        await _databaseRepository.validateTransaction(arguments.work.id!);

    emit(RespawnSuccess(reasons: reasons, enterpriseConfig: enterpriseConfig));

    if (validate == false) {
      await _navigationService.goTo(summaryRoute,
          arguments: SummaryArgument(work: arguments.work));
    } else {
      await _navigationService.goTo(workRoute,
          arguments: WorkArgument(work: arguments.work));
    }
  }
}
