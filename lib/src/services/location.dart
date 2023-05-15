import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

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

  static Future<LocationService?> getInstance() async {
    _instance ??= LocationService();
    return _instance;
  }

  bool inBackground = false;

  Future<bool> activateBackgroundMode() async {
    // var backgroundMode = await _preferences?.isBackgroundModeEnabled();
    //
    // if (backgroundMode! == false) {
    //   await _preferences?.enableBackgroundMode(enable: true);
    //   await _preferences?.changeNotificationOptions(
    //     title: 'Localización en segundo plano activa',
    //   );
    // }

    return Future.value(false);
  }

  // Keep track of current Location
  LocationData? _currentLocation;

  // Continuously emit location updates
  final StreamController<LocationData?> _locationController =
      StreamController<LocationData?>.broadcast();

  // ignore: sort_constructors_first
  LocationService() {
    Future.value(getPermissionStatus())
    .then((granted) {
      if (granted == PermissionStatus.authorizedAlways) {
        onLocationChanged(inBackground: inBackground).listen((locationData) {
          _locationController.add(locationData);
        });
      }
    });
  }

  Future<PermissionStatus> hasPermission() async {
    return await getPermissionStatus();
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

  Stream<LocationData?> get locationStream => _locationController.stream;

  Future<LocationData> getLocation() async {
    try {
      _currentLocation = await getLocation();
    } catch (e) {
      if (kDebugMode) {
        print('Could not get the location: $e');
      }
    }

    return _currentLocation!;
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
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          accuracy: locationData.accuracy,
          altitude: locationData.altitude,
          heading: locationData.bearing,
          isMock: locationData.isMock,
          speed: locationData.speed,
          speedAccuracy: locationData.speedAccuracy,
          userId: _storageService.getInt('user_id') ?? 0,
          time: DateTime.now());

      if (lastLocation != null) {
        var currentPosition = LatLng(location.latitude, location.longitude);
        var radiusPosition =
        LatLng(lastLocation.latitude, lastLocation.longitude);

        var diff =
        calculateRadiusBetweenTwoLatLng(currentPosition, radiusPosition, 30);

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
