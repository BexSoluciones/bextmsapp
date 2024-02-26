part of 'gps_bloc.dart';

abstract class GpsEvent extends Equatable {
  const GpsEvent();

  @override
  List<Object> get props => [];
}

class GpsAndPermissionEvent extends GpsEvent {
  final bool isGpsEnabled;
  final bool isGpsPermissionGranted;
  const GpsAndPermissionEvent(
      {required this.isGpsEnabled, required this.isGpsPermissionGranted});
}

class GpsShowDisabled extends GpsEvent {
  const GpsShowDisabled();
}

class OnNewUserLocationEvent extends GpsEvent {
  final LatLng newLocation;
  final Position currentPosition;
  const OnNewUserLocationEvent(this.currentPosition, this.newLocation);
}

class OnStartFollowingUser extends GpsEvent {}

class OnStopFollowingUser extends GpsEvent {}
