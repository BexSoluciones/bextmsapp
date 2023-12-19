const String tableLocations = 'locations';

class LocationFields {
  static final List<String> values = [
    id,
    latitude,
    longitude,
    type,
    workcode,
    time
  ];

  static const String id = 'id';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String accuracy = 'accuracy';
  static const String altitude = 'altitude';
  static const String speed = 'speed';
  static const String speedAccuracy = 'speed_accuracy';
  static const String heading = 'heading';
  static const String isMock = 'is_mock';
  static const String userId = 'user_id';
  static const String type = 'type';
  static const String send = 'send';
  static const String workcode = 'workcode';
  static const String time = 'time';
}

class Location {
  Location({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.speedAccuracy,
    required this.heading,
    required this.isMock,
    required this.userId,
    required this.time,
    this.send,
  });

  Location copy(
          {int? id,
          double? latitude,
          double? longitude,
          double? accuracy,
          double? altitude,
          double? speed,
          double? speedAccuracy,
          double? heading,
          bool? isMock,
          int? userId,
          int? send,
          DateTime? time}) =>
      Location(
        id: id ?? this.id,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        accuracy: accuracy ?? this.accuracy,
        altitude: altitude ?? this.altitude,
        speed: speed ?? this.speed,
        speedAccuracy: speedAccuracy ?? this.speedAccuracy,
        heading: heading ?? this.heading,
        isMock: isMock ?? this.isMock,
        userId: userId ?? this.userId,
        time: time ?? this.time,
        send: send ?? this.send,
      );

  // ignore: sort_constructors_first
  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json[LocationFields.id] as int?,
        latitude: json[LocationFields.latitude] is String
            ? double.parse(json[LocationFields.latitude])
            : json[LocationFields.latitude],
        longitude: json[LocationFields.longitude] is String
            ? double.parse(json[LocationFields.longitude])
            : json[LocationFields.longitude],
        accuracy: json[LocationFields.accuracy],
        altitude: json[LocationFields.altitude],
        speed: json[LocationFields.speed],
        speedAccuracy:
            json[LocationFields.speedAccuracy] ?? json['speedAccuracy'],
        heading: json[LocationFields.heading],
        isMock: json[LocationFields.isMock] == 1,
        userId: json[LocationFields.userId],
        send: json[LocationFields.send] is String
            ? int.parse(json[LocationFields.send])
            : json[LocationFields.send],
        time: DateTime.parse(json[LocationFields.time] as String),
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'altitude': altitude,
        'speed': speed,
        'speed_accuracy': speedAccuracy,
        'heading': heading,
        'is_mock': isMock != null && isMock == true ? 1 : 0,
        'user_id': userId,
        'send': send,
        'time': time.toIso8601String(),
      };

  int? id;
  double latitude;
  double longitude;
  double? accuracy;
  double? altitude;
  double? speed;
  double? speedAccuracy;
  double? heading;
  bool? isMock;
  int userId;
  int? send;
  DateTime time;
}
