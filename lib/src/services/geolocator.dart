import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:geolocator/geolocator.dart';

Future<Position?> acquireCurrentLocationGeo() async {
  bool serviceEnabled;
  LocationPermission permissionGranted;
  Position? position;

  for (int i = 0; i < 3; i++) {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await Geolocator.checkPermission();
    if (permissionGranted == LocationPermission.denied) {
      permissionGranted = await Geolocator.requestPermission();
      if (permissionGranted != LocationPermission.whileInUse &&
          permissionGranted != LocationPermission.always) {
        return null;
      }
    }

    try {
      position = await Geolocator.getCurrentPosition();
      if (position != null) {
        break;
      }
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
    await Future.delayed(const Duration(seconds: 1));
  }

  return position;
}
