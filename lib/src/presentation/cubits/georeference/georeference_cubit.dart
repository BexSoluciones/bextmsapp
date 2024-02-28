import 'dart:async';
import 'dart:convert';
import 'package:bexdeliveries/src/domain/models/arguments.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//utils
import '../../../domain/abstracts/format_abstract.dart';

//bloc
import '../../../utils/constants/strings.dart';
import '../../blocs/gps/gps_bloc.dart';
import '../../blocs/processing_queue/processing_queue_bloc.dart';

//domain
import '../../../domain/models/client.dart';
import '../../../domain/models/processing_queue.dart';
import '../../../domain/repositories/database_repository.dart';

//services
import '../../../locator.dart';
import '../../../services/navigation.dart';
import '../../../services/storage.dart';

part 'georeference_state.dart';

class GeoReferenceCubit extends Cubit<GeoReferenceState> with FormatDate {
  final DatabaseRepository databaseRepository;
  final ProcessingQueueBloc processingQueueBloc;
  final GpsBloc gpsBloc;
  final NavigationService navigationService;
  final LocalStorageService storageService;

  GeoReferenceCubit(
      this.databaseRepository, this.processingQueueBloc, this.gpsBloc, this.storageService, this.navigationService)
      : super(GeoReferenceInitial());

  Future<void> init() async {
    emit(GeoReferenceSuccess());
  }

  Future<void> sendTransactionClient(
      SummaryArgument argument, Client client) async {
    emit(GeoReferenceLoading());

    var currentLocation = gpsBloc.state.lastKnownLocation;

    client.latitude = currentLocation!.latitude.toString();
    client.longitude = currentLocation.longitude.toString();
    client.userId = storageService.getInt('user_id');

    await databaseRepository.insertClient(client);

    var processingQueue = ProcessingQueue(
        body: jsonEncode(client.toJson()),
        task: 'incomplete',
        code: 'update_client',
        createdAt: now(),
        updatedAt: now());

    processingQueueBloc
        .add(ProcessingQueueAdd(processingQueue: processingQueue));

    emit(GeoReferenceFinished());

    navigationService.goTo(AppRoutes.summary, arguments: argument);
  }
}
