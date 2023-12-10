part of 'gps_bloc.dart';

class GpsState extends Equatable {
  final bool isGpsEnabled;
  final bool isGpsPermissionGranted;

  //PROPERTIES TO CONTROLL USER GPS ACTION
  final bool followingUser;
  final LatLng? lastKnownLocation;
  final List<LatLng> myLocationHistory;

  bool get isAllGranted => isGpsEnabled && isGpsPermissionGranted;

  const GpsState(
      {required this.isGpsEnabled,
        required this.isGpsPermissionGranted,
        //PROPERTIES TO CONTROL USER GPS ACTION
        this.followingUser = false,
        this.lastKnownLocation,
        myLocationHistory})
      : myLocationHistory = myLocationHistory ?? const [];

  GpsState copyWith({
    bool? isGpsEnabled,
    bool? isGpsPermissionGranted,
    bool? followingUser,
    LatLng? lastKnownLocation,
    List<LatLng>? myLocationHistory,
  }) =>
      GpsState(
          isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
          isGpsPermissionGranted:
          isGpsPermissionGranted ?? this.isGpsPermissionGranted,

          //PROPERTIES TO CONTROLL USER GPS ACTION

          followingUser: followingUser ?? this.followingUser,
          lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
          myLocationHistory: myLocationHistory ?? this.myLocationHistory);

  @override
  List<Object?> get props => [
    isGpsEnabled,
    isGpsPermissionGranted,
    followingUser,
    myLocationHistory,
    lastKnownLocation
  ];

  @override
  String toString() =>
      '{ isGpsEnabled: $isGpsEnabled, isGpsPermissionGranted: $isGpsPermissionGranted }';
}
