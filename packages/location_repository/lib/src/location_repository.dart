import 'package:location/location.dart';
import 'package:location_repository/src/model/current_location.dart';

/// Failure model that implement error
class CurrentLocationFailure implements Exception {
  /// instance of failure model
  CurrentLocationFailure({
    required this.error,
  });

  /// the error name if something went wrong
  final String error;
}

class LocationRepository {

  /// {@macro location_repository}
  LocationRepository();

  /// instance of location
  final Location _location = Location();

  /// Function to get current location
  Future<CurrentUserLocationEntity> getCurrentLocation() async {
    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      throw CurrentLocationFailure(
        error: "You don't have location service enabled",
      );
    }

    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission == PermissionStatus.denied) {
        throw CurrentLocationFailure(
          error: "You don't have all the permissions granted."
              '\nYou need to activate them manually.',
        );
      }
    }

    if (permission == PermissionStatus.deniedForever) {
      throw CurrentLocationFailure(
        error: "You don't have all the permissions granted."
            '\nYou need to activate them manually.',
      );
    }

    late final LocationData position;

    try {
      position = await _location.getLocation();
    } catch (_) {
      throw CurrentLocationFailure(
        error: 'Something went wrong getting your location, '
            'please try again later',
      );
    }

    final latitude = position.latitude;
    final longitude = position.longitude;

    return CurrentUserLocationEntity(
      latitude: latitude!,
      longitude: longitude!,
    );
  }
}
