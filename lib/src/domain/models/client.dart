const String tableClients = 'clients';

class ClientFields {
  static final List<String> values = [
    id,
    latitude,
    longitude,
    nit,
    operativeCenter,
    action,
    userId
  ];

  static const String id = 'id';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String nit = 'nit';
  static const String operativeCenter = 'operative_center';
  static const String action = 'action';
  static const String userId = 'user_id';
}

class Client {
  Client(
      {this.id,
      this.nit,
      this.operativeCenter,
      this.latitude,
      this.longitude,
      this.action,
      this.userId});

  Client.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nit = json['nit'];
    operativeCenter = json['operative_center'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    action = json['action'];
    userId = json['user_id'] is String
        ? int.parse(json['user_id'])
        : json['user_id'];
  }

  int? id;
  String? nit;
  String? operativeCenter;
  String? latitude;
  String? longitude;
  String? action;
  int? userId;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['nit'] = nit;
    data['operative_center'] = operativeCenter;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['action'] = action;
    data['user_id'] = userId;
    return data;
  }
}
