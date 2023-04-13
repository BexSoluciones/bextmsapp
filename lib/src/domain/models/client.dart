
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
      { required this.nit,
        required this.operativeCenter,
        required this.latitude,
        required this.longitude,
        required this.action,
        required this.userId});

  Client.fromJson(Map<String, dynamic> json) {
    nit = json['nit'];
    operativeCenter = json['operative_center'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    action = json['action'];
    userId = json['user_id'];
  }

  String? nit;
  String? operativeCenter;
  String? latitude;
  String? longitude;
  String? action;
  String? userId;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nit'] = nit;
    data['operative_center'] = operativeCenter;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['action'] = action;
    data['user_id'] = userId;
    return data;
  }
}