part of 'location_bloc.dart';

enum LocationStateStatus { initial, success, error, loading }

extension LocationStateStatusX on LocationStateStatus {
  bool get isInitial => this == LocationStateStatus.initial;
  bool get isSuccess => this == LocationStateStatus.success;
  bool get isError => this == LocationStateStatus.error;
  bool get isLoading => this == LocationStateStatus.loading;
}

class LocationState extends Equatable {
  LocationState({
    this.status = LocationStateStatus.initial,
    LatLng? initLocation,
    CurrentUserLocationEntity? currentUserLocation,
    String? errorMessage,
  })  : currentUserLocation =
      currentUserLocation ?? CurrentUserLocationEntity.empty,
        initLocation = initLocation ?? LatLng(40.4167, -3.70325),
        errorMessage = errorMessage ?? '';

  final LocationStateStatus status;
  final CurrentUserLocationEntity currentUserLocation;
  final LatLng initLocation;
  final String errorMessage;

  @override
  List<Object?> get props => [
    status,
    currentUserLocation,
    initLocation,
    errorMessage,
  ];

  LocationState copyWith({
    LocationStateStatus? status,
    CurrentUserLocationEntity? currentUserLocation,
    LatLng? initLocation,
    CurrentUserLocationEntity? location,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      currentUserLocation: currentUserLocation ?? this.currentUserLocation,
      initLocation: initLocation ?? this.initLocation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}