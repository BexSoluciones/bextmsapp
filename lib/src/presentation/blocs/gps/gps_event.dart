part of 'gps_bloc.dart';

abstract class GpsEvent extends Equatable {
  const GpsEvent();

  @override
  List<Object> get props => [];
}

class GpsPermissionGranted extends GpsEvent {
  final bool isGpsPermissionGranted;
  const GpsPermissionGranted({ required this.isGpsPermissionGranted });
}

class GpsEnabled extends GpsEvent {
  final bool isGpsEnabled;
  const GpsEnabled({ required this.isGpsEnabled });
}

class ShowErrorDialog extends GpsEvent {
  const ShowErrorDialog();
}

class OnNewUserLocationEvent extends GpsEvent {
  final LatLng newLocation;
  final Position currentPosition;
  const OnNewUserLocationEvent(this.currentPosition, this.newLocation);
}

class OnStartFollowingUser extends GpsEvent {}

class OnStopFollowingUser extends GpsEvent {}
