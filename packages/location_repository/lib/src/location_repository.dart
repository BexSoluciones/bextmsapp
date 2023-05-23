import 'package:location/location.dart';
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

/// {@template location_repository}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class LocationRepository {
  /// {@macro location_repository}
  LocationRepository();

  /// Function to get current location
  Future<CurrentUserLocationEntity> getCurrentLocation() async {
    // final serviceEnabled = await isGPSEnabled();
    // if (!serviceEnabled) {
    //   throw CurrentLocationFailure(
    //     error: "You don't have location service enabled",
    //   );
    // }

    // final permissionStatus = await requestPermission();
    // if (permissionStatus == PermissionStatus.denied) {
    //   final status = await requestPermission();
    //   if (status != PermissionStatus.authorizedAlways) {
    //     throw CurrentLocationFailure(
    //       error: "You don't have all the permissions granted."
    //           '\nYou need to activate them manually.',
    //     );
    //   }
    // }

    late final LocationData locationData;
    try {
      locationData = await getLocation();
    } catch (_) {
      throw CurrentLocationFailure(
        error: 'Something went wrong getting your location, '
            'please try again later',
      );
    }

    final latitude = locationData.latitude;
    final longitude = locationData.longitude;

    if (latitude == null || longitude == null) {
      throw CurrentLocationFailure(
        error: 'Something went wrong getting your location, '
            'please try again later',
      );
    }

    return CurrentUserLocationEntity(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
