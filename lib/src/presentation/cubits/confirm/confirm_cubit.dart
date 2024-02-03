import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';

//utils
import '../../../domain/models/arguments.dart';
import '../../../utils/constants/strings.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/models/transaction.dart';
//abstracts
import '../../../domain/abstracts/format_abstract.dart';
//repositories
import '../../../domain/repositories/database_repository.dart';

//base
import '../../blocs/gps/gps_bloc.dart';
import '../base/base_cubit.dart';
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//services
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'confirm_state.dart';

class ConfirmCubit extends BaseCubit<ConfirmState, String?> with FormatDate {
  final DatabaseRepository _databaseRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final GpsBloc gpsBloc;
  final LocalStorageService storageService;
  final NavigationService navigationService;

  ConfirmCubit(this._databaseRepository, this._processingQueueBloc, this.gpsBloc, this.storageService, this.navigationService) : super(const ConfirmLoading(), null);

  Future<void> init(Work work) async {
    emit(await _getWork(work));
  }

  Future<ConfirmState> _getWork(Work work) async {
    return ConfirmSuccess(work: work);
  }

  Future<void> confirm(WorkArgument arguments) async {
    if (isBusy) return;

    await run(() async {
      emit(const ConfirmLoading());

      var currentLocation = gpsBloc.state.lastKnownLocation;

      storageService.setBool('${arguments.work.workcode}-started', true);

      var processingQueueStatus = ProcessingQueue(
          body: jsonEncode({
            'workcode': arguments.work.workcode,
            'status': 'incomplete'
          }),
          task: 'incomplete',
          code: 'store_work_status',
          createdAt: now(),
          updatedAt: now(),
      );

      _processingQueueBloc.add(ProcessingQueueAdd(processingQueue: processingQueueStatus));

      var transaction = Transaction(
          workId: arguments.work.id!,
          workcode: arguments.work.workcode,
          status: 'start',
          start: now(),
          end: now(),
          latitude: currentLocation?.latitude.toString(),
          longitude: currentLocation?.longitude.toString(),
       );

      await _databaseRepository.insertTransaction(transaction);

      var processingQueueTransaction = ProcessingQueue(
          body: jsonEncode(transaction.toJson()),
          task: 'incomplete',
          code: 'store_transaction_start',
          createdAt: now(),
          updatedAt: now()
       );

      _processingQueueBloc.add(ProcessingQueueAdd(processingQueue: processingQueueTransaction));

      navigationService.goTo(AppRoutes.work, arguments: arguments);

    });
  }

  Future<void> out(arguments) async  {
    storageService.setBool('${arguments.work.workcode}-started', false);
    navigationService.goTo(AppRoutes.work, arguments: arguments);
  }
}
