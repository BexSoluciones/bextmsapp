import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_repository/location_repository.dart';

//bloc
import '../../blocs/location/location_bloc.dart';

//domain
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/models/client.dart';

part 'georeference_state.dart';

class GeoreferenceCubit extends Cubit<GeoreferenceState> {
  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;

  CurrentUserLocationEntity? currentLocation;

  GeoreferenceCubit(this._databaseRepository, this._locationRepository) : super(GeoreferenceSuccess());

  Future<void> sendTransactionClient(Client client) async {

    emit(GeoreferenceLoading());

    currentLocation = await _locationRepository.getCurrentLocation();

    client.latitude = currentLocation!.latitude.toString();
    client.longitude = currentLocation!.longitude.toString();





    // await _databaseRepository.insertTransaction(client);



    emit(GeoreferenceFinished());
  }





}
