import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:location_repository/location_repository.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/models/location.dart' as l;
import '../../../domain/repositories/database_repository.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {

  final LocationRepository locationRepository;
  final DatabaseRepository databaseRepository;

  LocationBloc({
    required this.locationRepository,
    required this.databaseRepository
  }) : super(LocationState()) {
    on<GetLocation>(_getLocationEvent);
  }

  Stream<List<l.Location>> get locations {
    return databaseRepository.watchAllLocations();
  }


  void _getLocationEvent(GetLocation event, Emitter<LocationState> emit) async {
    try {
      emit(state.copyWith(status: LocationStateStatus.loading));

      var currentLocation = await locationRepository.getCurrentLocation();

      emit(
        state.copyWith(
          currentUserLocation: currentLocation,
          status: LocationStateStatus.success,
        ),
      );
    } on CurrentLocationFailure catch (e) {
      emit(
        state.copyWith(
          status: LocationStateStatus.error,
          errorMessage: e.error,
        ),
      );
      // This is important to check errors on tests.
      // Also you can see the error on the [BlocObserver.onError].
      addError(e);
    }
  }
}
