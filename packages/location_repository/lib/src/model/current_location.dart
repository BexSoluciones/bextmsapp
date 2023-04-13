/// model of current location entity
class CurrentUserLocationEntity {
  /// instance of current location entity
  const CurrentUserLocationEntity({
    required this.latitude,
    required this.longitude,
  });
  /// latitude
  final double latitude;
  /// longitude
  final double longitude;
  /// empty location
  static const empty = CurrentUserLocationEntity(latitude: 0, longitude: 0);
}
