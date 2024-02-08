import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
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

//utils
import '../../../utils/constants/strings.dart';

//services
import '../../../services/navigation.dart';
import '../../../services/storage.dart';
import '../../../services/logger.dart';

//widgets
import '../../widgets/error_alert_dialog.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> with FormatDate {
  final NavigationService navigationService;
  final LocalStorageService storageService;
  final DatabaseRepository databaseRepository;

  StreamSubscription? gpsServiceSubscription;
  StreamSubscription? positionStream;
  LatLng? lastRecordedLocation;
  bool showingDialog = false;

  GpsBloc(
      {required this.navigationService,
      required this.storageService,
      required this.databaseRepository})
      : super(const GpsInitial(
            isGpsEnabled: false, isGpsPermissionGranted: false)) {
    on<GpsPermissionGranted>(_requestPermissions);
    on<GpsEnabled>(_checkGpsStatus);
    on<ShowErrorDialog>(_showErrorDialog);
    on<OnStartFollowingUser>(startFollowingUser);
    on<OnStopFollowingUser>(stopFollowingUser);
    on<OnNewUserLocationEvent>((event, emit) {
      final updatedState = state.copyWith(
        lastKnownLocation: event.newLocation,
        isGpsEnabled: true,
      );
      emit(updatedState);
    });
    _init();
  }

  Future<void> _requestPermissions(GpsPermissionGranted event, emit) async {
    try {
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (isLocationEnabled) {
        emit(const GpsPermissionGranted(isGpsPermissionGranted: true));
      } else {
        emit(const GpsPermissionGranted(isGpsPermissionGranted: false));
      }
    } catch (e) {
      emit(GpsFailed(
          isGpsEnabled: false,
          isGpsPermissionGranted: false,
          error: e.toString()));
    }
  }

  Future<bool?> _checkGpsStatus(GpsEnabled event, emit) async {
    try {
      final isEnable = await Geolocator.isLocationServiceEnabled();

      gpsServiceSubscription =
          Geolocator.getServiceStatusStream().listen((event) {
            final isEnabled = (event.index == 1) ? true : false;
            if (isEnabled == false && showingDialog == false) {
              errorGpsAlertDialog(
                  onTap: () {
                    Geolocator.openLocationSettings();
                  },
                  context:
                  navigationService.navigatorKey.currentState!.overlay!.context,
                  error: 'error',
                  iconData: Icons.error,
                  buttonText: 'buttonText');
              showingDialog = true;
            } else {
              if (showingDialog) {
                Navigator.pop(
                    navigationService.navigatorKey.currentState!.overlay!.context);
                showingDialog = false;
              }
            }
            add(GpsPermissionGranted(
              isGpsPermissionGranted: state.isGpsPermissionGranted,
            ));
          });

      return isEnable;
    } catch (e) {
      emit(GpsFailed(
          isGpsEnabled: state.isGpsEnabled,
          isGpsPermissionGranted: false,
          error: e.toString()));
    }
  }

  Future<void> _init() async {
    final gpsInitStatus = await Future.wait([
      _checkGpsStatus(const GpsEnabled(isGpsEnabled: false),null),
      _isPermissionGranted(),
    ]);

    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      add(OnStartFollowingUser());
    }
    add(GpsPermissionGranted(
      isGpsPermissionGranted: gpsInitStatus[0]!,
    ));
  }


  Future<void> askGpsAccess() async {
    final status = await Permission.location.request();

    switch (status) {
      case PermissionStatus.granted:
        //TODO [Heider Zapa]
        // add(GpsAndPermissionEvent(
        //     isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: true));
        break;
      case PermissionStatus.denied:
        break;
      case PermissionStatus.restricted:
        return;
      case PermissionStatus.limited:
        break;
      case PermissionStatus.permanentlyDenied:
        //TODO [Heider Zapa]
        // add(GpsAndPermissionEvent(
        //     isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: false));
        openAppSettings();
        break;
      case PermissionStatus.provisional:
        // TODO: Handle this case.
        break;
    }
  }

  Future<void> startFollowingUser(OnStartFollowingUser event, emit) async {
    try {
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      final isPermissionGranted = await _isPermissionGranted();

      if (!isPermissionGranted) {
        await askGpsAccess();
      }

      EnterpriseConfig? enterpriseConfig = _getEnterpriseConfigFromStorage();

      if (enterpriseConfig != null) {
        LocationSettings locationSettings = _getLocationSettings(
            enterpriseConfig, isPermissionGranted, isLocationEnabled);

        if (!isPermissionGranted && !isLocationEnabled) {
          emit(const ShowErrorDialog());
        } else {
          positionStream =
              Geolocator.getPositionStream(locationSettings: locationSettings)
                  .listen((event) {
            _handleUserLocation(event, enterpriseConfig);
          });
        }
      }
    } catch (e, stackTrace) {
      await _handleError(e, stackTrace);
    }
  }

  Future<void> stopFollowingUser(OnStopFollowingUser event, emit) async {
    try {
      positionStream?.cancel();
    } catch (e, stackTrace) {
      await _handleError(e, stackTrace);
    }
  }

  EnterpriseConfig? _getEnterpriseConfigFromStorage() {
    var storedConfig = storageService.getObject('config');
    return storedConfig != null ? EnterpriseConfig.fromMap(storedConfig) : null;
  }

  LocationSettings _getLocationSettings(EnterpriseConfig enterpriseConfig,
      bool isPermissionGranted, bool isLocationEnabled) {
    var distances = enterpriseConfig.distance!;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "Servicio de ubicación en segundo plano en ejecución",
          notificationTitle: "Bexdeliveries",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: distances,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
  }

  Future<void> _handleUserLocation(
      Position position, EnterpriseConfig enterpriseConfig) async {
    final distances = enterpriseConfig.distance!;
    final lastKnownLocation = state.lastKnownLocation;
    final isBackgroundLocationEnabled =
        enterpriseConfig.backgroundLocation ?? false;

    if (isBackgroundLocationEnabled && lastRecordedLocation != null) {
      final distance = Geolocator.distanceBetween(
        lastRecordedLocation!.latitude,
        lastRecordedLocation!.longitude,
        position.latitude,
        position.longitude,
      );

      if (distance >= distances) {
        lastRecordedLocation = LatLng(position.latitude, position.longitude);
        await saveLocation('location', position, 0);
      }
    } else {
      lastRecordedLocation = LatLng(position.latitude, position.longitude);
      await saveLocation('location', position, 1);
    }

    add(OnNewUserLocationEvent(
        position, LatLng(position.latitude, position.longitude)));
  }

  Future<void> _handleError(dynamic e, StackTrace stackTrace) async {
    await FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }

  _showErrorDialog(ShowErrorDialog event, Emitter emit) async {
    if (state.isAllGranted) {
      errorGpsAlertDialog(
          onTap: () {
            Geolocator.openLocationSettings();
          },
          context:
              navigationService.navigatorKey.currentState!.overlay!.context,
          error: 'error',
          iconData: Icons.error,
          buttonText: 'buttonText');
    }
  }

  Future<bool> _isPermissionGranted() async {
    final isGranted = await Permission.location.isGranted;
    return isGranted;
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

  Future<void> saveLocation(String type, Position position, int send) async {
    try {
      var lastLocation = await databaseRepository.getLastLocation();
      var location = l.Location(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          heading: position.heading,
          isMock: position.isMocked,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
          userId: storageService.getInt('user_id') ?? 0,
          time: DateTime.now(),
          send: 0);

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
            storageService.setBool('is_walking', true);
          } else if (speed > 10) {
            storageService.setBool('is_walking', false);
          }

          await databaseRepository.insertLocation(location);
        } else {
          logDebugFine(headerDeveloperLogger, 'no se ha movido');
        }
      } else {
        await databaseRepository.insertLocation(location);
      }

      var count = await databaseRepository.countLocationsManager();
      if (count) {
        var processingQueue = ProcessingQueue(
            body: await databaseRepository.getLocationsToSend(),
            task: 'incomplete',
            code: 'store_locations',
            createdAt: now(),
            updatedAt: now());

        await databaseRepository.insertProcessingQueue(processingQueue);
        await databaseRepository.updateLocationsManager();
      }
    } catch (e, stackTrace) {
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
