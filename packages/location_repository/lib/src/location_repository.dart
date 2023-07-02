import 'package:geolocator/geolocator.dart';
import 'package:location_repository/src/model/current_location.dart';

/// Failure model that implement error
class CurrentLocationFailure implements Exception {
  /// instance of failure model
  CurrentLocationFailure({
    required this.error,
  });

  /// the error name if somethig went wrong
  final String error;
}

class LocationRepository {
  /// {@macro location_repository}
  LocationRepository();

  /// Function to get current location
  Future<CurrentUserLocationEntity> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw CurrentLocationFailure(
        error: "You don't have location service enabled",
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw CurrentLocationFailure(
          error: "You don't have all the permissions granted."
              '\nYou need to activate them manually.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw CurrentLocationFailure(
        error: "You don't have all the permissions granted."
            '\nYou need to activate them manually.',
      );
    }


    late final Position position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (_) {
      throw CurrentLocationFailure(
        error: 'Something went wrong getting your location, '
            'please try again later',
      );
    }

    final latitude = position.latitude;
    final longitude = position.longitude;


    return CurrentUserLocationEntity(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
