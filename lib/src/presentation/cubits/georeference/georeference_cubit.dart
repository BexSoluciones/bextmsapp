import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_repository/location_repository.dart';

//utils
import '../../../domain/abstracts/format_abstract.dart';

//bloc
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

final NavigationService _navigationService = locator<NavigationService>();
final LocalStorageService _storageService = locator<LocalStorageService>();

class GeoreferenceCubit extends Cubit<GeoreferenceState> with FormatDate {
  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;
  final ProcessingQueueBloc _processingQueueBloc;
  final GpsBloc gpsBloc;
  CurrentUserLocationEntity? currentLocation;

  GeoreferenceCubit(this._databaseRepository, this._locationRepository, this._processingQueueBloc,this.gpsBloc) : super(GeoreferenceSuccess());

  Future<void> sendTransactionClient(Client client) async {

    emit(GeoreferenceLoading());

    //currentLocation = await _locationRepository.getCurrentLocation();
    var currentLocation = gpsBloc.state.lastKnownLocation;

    client.latitude = currentLocation!.latitude.toString();
    client.longitude = currentLocation.longitude.toString();
    client.userId = _storageService.getInt('user_id');

    await _databaseRepository.insertClient(client);

    var processingQueue = ProcessingQueue(
        body: jsonEncode(client.toJson()),
        task: 'incomplete',
        code: 'LLKFNVLKNE',
        createdAt: now(),
        updatedAt: now());

    _processingQueueBloc
        .add(ProcessingQueueAdd(processingQueue: processingQueue));

    emit(GeoreferenceFinished());

    _navigationService.goBack();

  }

}
