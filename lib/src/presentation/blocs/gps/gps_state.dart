part of 'gps_bloc.dart';

class GpsState extends Equatable {
  final bool isGpsEnabled;
  final bool isGpsPermissionGranted;
  final bool showDialog;
  final bool followingUser;
  final LatLng? lastKnownLocation;

  bool get isAllGranted => isGpsEnabled && isGpsPermissionGranted;

  const GpsState(
      {required this.isGpsEnabled,
      required this.isGpsPermissionGranted,
      this.showDialog = false,
      this.followingUser = false,
      this.lastKnownLocation,
      myLocationHistory});

  GpsState copyWith({
    bool? isGpsEnabled,
    bool? isGpsPermissionGranted,
    bool? followingUser,
    bool? showDialog,
    LatLng? lastKnownLocation,
    List<LatLng>? myLocationHistory,
  }) =>
      GpsState(
          isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
          isGpsPermissionGranted:
              isGpsPermissionGranted ?? this.isGpsPermissionGranted,
          showDialog: showDialog ?? this.showDialog,
          followingUser: followingUser ?? this.followingUser,
          lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation);

  @override
  List<Object?> get props => [
        isGpsEnabled,
        isGpsPermissionGranted,
        showDialog,
        followingUser,
        lastKnownLocation
      ];

  @override
  String toString() =>
      '{ isGpsEnabled: $isGpsEnabled, '
          'isGpsPermissionGranted: $isGpsPermissionGranted, '
          'showDialog: $showDialog }';
}

class GpsInitial extends GpsState {
  const GpsInitial(
      {required super.isGpsEnabled, required super.isGpsPermissionGranted});
}

class GpsLoading extends GpsState {
  const GpsLoading(
      {required super.isGpsEnabled, required super.isGpsPermissionGranted});
}

class GpsFailed extends GpsState {
  final String error;
  const GpsFailed(
      {this.error = "GpsFailed",
      required super.isGpsEnabled,
      required super.isGpsPermissionGranted});

  @override
  List<Object> get props => [error];
}

class GpsSuccess extends GpsState {
  const GpsSuccess(
      {required super.isGpsEnabled, required super.isGpsPermissionGranted});
}
