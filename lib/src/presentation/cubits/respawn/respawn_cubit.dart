import 'dart:async';
import 'dart:convert';
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
import '../../../domain/models/transaction.dart';
import '../../../domain/abstracts/format_abstract.dart';
import '../../../domain/repositories/database_repository.dart';

//service
import '../../../locator.dart';
import '../../../services/navigation.dart';

part 'respawn_state.dart';


final NavigationService _navigationService = locator<NavigationService>();

class RespawnCubit extends Cubit<RespawnState> with FormatDate {
  final DatabaseRepository _databaseRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final LocationRepository _locationRepository;

  CurrentUserLocationEntity? currentLocation;

  RespawnCubit(this._databaseRepository, this._locationRepository,
      this._processingQueueBloc)
      : super(const RespawnSuccess());

  Future<void> confirmTransaction(InventoryArgument arguments) async {
    emit(const RespawnLoading());

    var transaction = Transaction(
        workId: arguments.work.id!,
        summaryId: arguments.summaryId,
        workcode: arguments.work.workcode,
        orderNumber: arguments.orderNumber,
        operativeCenter: arguments.operativeCenter,
        status: 'reject',
        firm: null);

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

    _processingQueueBloc.add(ProcessingQueueAdd(processingQueue: processingQueue));

    var validate =
        await _databaseRepository.validateTransaction(arguments.work.id!);

    if (validate == false) {
      await _navigationService.goTo(summaryRoute,
          arguments: SummaryArgument(work: arguments.work));
    } else {
      await _navigationService.goTo(workRoute,
          arguments: WorkArgument(work: arguments.work));
    }
  }
}
