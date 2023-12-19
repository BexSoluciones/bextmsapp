const String tableConfirms = 'confirms';

class ConfirmFields {
  static final List<String> values = [
    id,
    workcode,
    latitude,
    longitude,
    createdAt,
  ];

  static const String id = 'id';
  static const String workcode = 'workcode';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String createdAt = 'created_at';
}

class Confirm {
  Confirm(
      {this.id,
        required this.workcode,
        required this.latitude,
        required this.longitude,
        required this.createdAt});

  Confirm copy({
    int? id,
  }) =>
      Confirm(
          id: id ?? this.id,
          workcode: workcode,
          latitude: latitude,
          longitude: longitude,
          createdAt: createdAt
      );

  // ignore: sort_constructors_first
  Confirm.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workcode = json['workcode'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['workcode'] = workcode;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['created_at'] = createdAt;
    return data;
  }

  int? id;
  late String workcode;
  late String latitude;
  late String longitude;
  late String createdAt;
}