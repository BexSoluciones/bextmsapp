import 'dart:async';
import 'dart:convert';
import 'dart:isolate';


import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

//domain
import '../../src/domain/models/location.dart' as l;
import '../domain/models/processing_queue.dart';
import '../../src/domain/abstracts/format_abstract.dart';
import '../../src/domain/repositories/database_repository.dart';

//services
import '../../src/locator.dart';
import '../../src/services/storage.dart';

final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();
final LocalStorageService _storageService = locator<LocalStorageService>();

class LocationService with FormatDate {
  static LocationService? _instance;
  static Geolocator? _geolocator;
  static SharedPreferences? _preferences;

  static Future<LocationService?> getInstance() async {
    _instance ??= LocationService();
    _geolocator ??= Geolocator();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance;
  }

  bool inBackground = false;

  // Keep track of current Location
  Position? _currentLocation;

  Future<bool> activateBackgroundMode() async {

    var backgroundMode = _preferences?.getBool('backgroundMode') ?? false;

    if (!backgroundMode) {
      await _preferences?.setBool('backgroundMode', true);
      await Geolocator.openAppSettings(); // Open app settings to enable background location permission

    }
    return backgroundMode;

  }

  // Continuously emit location updates
  final StreamController<Position?> _locationController =
  StreamController<Position?>.broadcast();

  // ignore: sort_constructors_first
  /*LocationService() {
    Geolocator.getPositionStream().listen((position) {
      _locationController.add(position);
    });
  }*/

  Future<LocationPermission?> hasPermission() async {
    if(_geolocator == null) return null;
    return await Geolocator.checkPermission();
  }

  bool calculateRadiusBetweenTwoLatLng(
      LatLng currentPosition, LatLng radiusPosition, double radius) {
    var distance = const Distance();
    var haversineDistance =
        distance.as(LengthUnit.Meter, currentPosition, radiusPosition);
    if (haversineDistance >= radius) {
      return true;
    } else {
      return false;
    }
  }

  double calculateDistanceBetweenTwoLatLng(
      LatLng currentPosition, LatLng radiusPosition) {
    var distance = const Distance();
    return distance.as(LengthUnit.Meter, currentPosition, radiusPosition);
  }

  int calculateDateBetweenTwoLatLng(DateTime date1, DateTime date2) {
    return date1.difference(date2).inSeconds;
  }

  Stream<Position?> get locationStream => _locationController.stream;

  Future sendLocation(SendPort port, location) {
    var response = ReceivePort();
    port.send([location, response.sendPort]);
    return response.first;
  }

  Future<Position?> getLocation() async {
    Position? currentLocation;
    var maxAttempts = 3;
    var attempts = 0;

    while (currentLocation == null && attempts < maxAttempts) {
      try {
        currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 5));
      } catch (e,stackTrace) {
        print('Could not get the location: $e');
        //await helperFunctions.handleException(e,stackTrace);
        attempts++;
        await Future.delayed(
            const Duration(seconds: 1));
      }
    }

    return currentLocation;
  }

  Future<void> saveLocation(String type) async {
    try {
      var lastLocation = await _databaseRepository.getLastLocation();

      var locationData = await Future.any([
        getLocation(),
        Future.delayed(const Duration(seconds: 3), () => null),
      ]);

      locationData ??= await getLocation();

      var location = l.Location(
          latitude: locationData!.latitude,
          longitude: locationData.longitude,
          accuracy: locationData.accuracy,
          altitude: locationData.altitude,
          heading: locationData.heading,
          isMock: locationData.isMocked,
          speed: locationData.speed,
          speedAccuracy: locationData.speedAccuracy,
          userId: _storageService.getInt('user_id') ?? 0,
          time: DateTime.now());

      if (lastLocation != null) {
        var currentPosition = LatLng(location.latitude, location.longitude);
        var radiusPosition =
            LatLng(lastLocation.latitude, lastLocation.longitude);

        var diff = calculateRadiusBetweenTwoLatLng(
            currentPosition, radiusPosition, 30);

        var distance =
            calculateDistanceBetweenTwoLatLng(currentPosition, radiusPosition);
        var seconds =
            calculateDateBetweenTwoLatLng(location.time, lastLocation.time);

        var speed = ((distance / seconds) * 18) / 5;

        if (diff == true) {
          if (speed < 10) {
            _storageService.setBool('is_walking', true);
          } else if (speed > 10) {
            _storageService.setBool('is_walking', false);
          }

          await _databaseRepository.insertLocation(location);

          var processingQueue = ProcessingQueue(
              body: jsonEncode(location.toJson()),
              task: 'incomplete',
              code: 'VNAIANBTLM',
              createdAt: now(),
              updatedAt: now());

          await _databaseRepository.insertProcessingQueue(processingQueue);
        } else {
          print('no se ha movido');
        }
      } else {
        var processingQueue = ProcessingQueue(
          body: jsonEncode(location.toJson()),
          task: 'incomplete',
          code: 'VNAIANBTLM',
          createdAt: now(),
          updatedAt: now(),
        );

        await _databaseRepository.insertLocation(location);
        await _databaseRepository.insertProcessingQueue(processingQueue);
      }
    } catch (e) {
      print('error saving ---- $e');
    }
  }
}
