import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:latlong2/latlong.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

//domain
import '../../../domain/models/enterprise_config.dart';
import '../../../domain/models/location.dart' as l;
import '../../../domain/models/processing_queue.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../domain/abstracts/format_abstract.dart';

//services
import '../../../locator.dart';
import '../../../services/navigation.dart';
import '../../../services/storage.dart';

//widgets
import '../../widgets/error_alert_dialog.dart';

part 'gps_event.dart';
part 'gps_state.dart';

final NavigationService _navigationService = locator<NavigationService>();
final LocalStorageService _storageService = locator<LocalStorageService>();
final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

LatLng? lastRecordedLocation;

class GpsBloc extends Bloc<GpsEvent, GpsState> with FormatDate {
  StreamSubscription? gpsServiceSubscription;
  StreamSubscription? positionStream;

  GpsBloc()
      : super(const GpsState(
            isGpsEnabled: false, isGpsPermissionGranted: false)) {
    on<GpsAndPermissionEvent>((event, emit) => emit(state.copyWith(
        isGpsEnabled: event.isGpsEnabled,
        isGpsPermissionGranted: event.isGpsPermissionGranted)));
    on<ShowErrorDialog>(_showErrorDialog);

    on<OnStartFollowingUser>(
        (event, emit) => emit(state.copyWith(followingUser: true)));
    on<OnStopFollowingUser>(
        (event, emit) => emit(state.copyWith(followingUser: false)));
    on<OnNewUserLocationEvent>((event, emit) {
      emit(state.copyWith(
        lastKnownLocation: event.newLocation,
        myLocationHistory: [...state.myLocationHistory, event.newLocation],
      ));
    });
    _init();
  }

  Future<void> startFollowingUser() async {
    add(OnStartFollowingUser());
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    final isPermissionGranted = await _isPermissionGranted();
    if (!isPermissionGranted) {
      await askGpsAccess();
    }

    try {
      var storedConfig = _storageService.getObject('config');
      var enterpriseConfig = EnterpriseConfig.fromMap(storedConfig!);
      var distances = enterpriseConfig.distance!;
      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: enterpriseConfig.distance!,
      );
      if (!isPermissionGranted && !isLocationEnabled) {
        errorGpsAlertDialog(
            onTap: () {
              Geolocator.openLocationSettings();
            },
            context:
                _navigationService.navigatorKey.currentState!.overlay!.context,
            error: 'error',
            iconData: Icons.error,
            buttonText: 'buttonText');
      } else {
        positionStream =
            Geolocator.getPositionStream(locationSettings: locationSettings)
                .listen((event) {
          final position = event;

          print(
              'Las known location :${state.lastKnownLocation?.latitude}${state.lastKnownLocation?.longitude}}');
          print('position: ${position.latitude},${position.longitude}');
          //TODO:: [Heider Zapa] activate processing queue

          if (enterpriseConfig.background_location!) {
            if (lastRecordedLocation != null) {
              final distance = Geolocator.distanceBetween(
                lastRecordedLocation!.latitude,
                lastRecordedLocation!.longitude,
                position.latitude,
                position.longitude,
              );
              if (distance >= distances) {
                lastRecordedLocation =
                    LatLng(position.latitude, position.longitude);
                saveLocation('location', position, lastRecordedLocation!);
              }
            } else {
              lastRecordedLocation =
                  LatLng(position.latitude, position.longitude);
              saveLocation('location', position, lastRecordedLocation!);
            }
          }
          add(OnNewUserLocationEvent(
              LatLng(position.latitude, position.longitude)));
        });
        print('StartFollowingUser');
      }
    } catch (e, stackTrace) {
      print('Error GPS:${e.toString()}');
      //await FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
  }

  Future getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      add(OnNewUserLocationEvent(
          LatLng(position.latitude, position.longitude)));
      print('Position: ${position.latitude}-${position.longitude}');
    } catch (e) {
      print('Error getCurrentPosition: GPS:${e.toString()}');
    }
  }

  void stopFollowingUser() {
    add(OnStopFollowingUser());
    positionStream?.cancel();
    print('stopFollowingUser');
  }

  Future<void> _init() async {
    final gpsInitStatus = await Future.wait([
      _checkGpsStatus(),
      _isPermissionGranted(),
    ]);
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      startFollowingUser();
    }
    add(GpsAndPermissionEvent(
      isGpsEnabled: gpsInitStatus[0],
      isGpsPermissionGranted: gpsInitStatus[1],
    ));
  }

  _showErrorDialog(ShowErrorDialog event, Emitter emit) async {
    if (state.isAllGranted) {
      errorGpsAlertDialog(
          onTap: () {
            Geolocator.openLocationSettings();
          },
          context:
              _navigationService.navigatorKey.currentState!.overlay!.context,
          error: 'error',
          iconData: Icons.error,
          buttonText: 'buttonText');
    }
  }

  Future<bool> _isPermissionGranted() async {
    final isGranted = await Permission.location.isGranted;
    return isGranted;
  }

  bool showingDialog = false;
  Future<bool> _checkGpsStatus() async {
    final isEnable = await Geolocator.isLocationServiceEnabled();

    gpsServiceSubscription =
        Geolocator.getServiceStatusStream().listen((event) {
      final isEnabled = (event.index == 1) ? true : false;
      if (isEnabled == false && showingDialog == false) {
        add(const ShowErrorDialog());
        showingDialog = true;
      } else {
        if (showingDialog) {
          Navigator.pop(
              _navigationService.navigatorKey.currentState!.overlay!.context);
          showingDialog = false;
        }
      }
      add(GpsAndPermissionEvent(
        isGpsEnabled: isEnabled,
        isGpsPermissionGranted: state.isGpsPermissionGranted,
      ));
    });

    return isEnable;
  }

  Future<void> askGpsAccess() async {
    final status = await Permission.location.request();

    switch (status) {
      case PermissionStatus.granted:
        add(GpsAndPermissionEvent(
            isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: true));
        break;

      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        add(GpsAndPermissionEvent(
            isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: false));
        openAppSettings();
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

  Future<void> saveLocation(
      String type, Position position, LatLng currentLocation) async {
    try {
      var lastLocation = await _databaseRepository.getLastLocation();

      var location = l.Location(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          heading: position.heading,
          isMock: position.isMocked,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
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
        } else {
          print('no se ha movido');
        }
      } else {
        await _databaseRepository.insertLocation(location);
      }

      var count = await _databaseRepository.countLocationsManager();

      if(count){
        var processingQueue = ProcessingQueue(
            body: await _databaseRepository.getLocationsToSend(),
            task: 'incomplete',
            code: 'store_locations',
            createdAt: now(),
            updatedAt: now());

        await _databaseRepository.insertProcessingQueue(processingQueue);
        await _databaseRepository.updateLocationsManager();
      }



    } catch (e, stackTrace) {
      print('error saving ---- $e');
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
  }

  @override
  Future<void> close() {
    gpsServiceSubscription?.cancel();
    positionStream?.cancel();
    return super.close();
  }
}
