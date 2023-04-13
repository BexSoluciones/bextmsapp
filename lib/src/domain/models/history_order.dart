import 'dart:convert';

const String tableHistoryOrders = 'history_order';

class HistoryOrderFields {
  static final List<String> values = [
    id,
    workId,
    workcode,
    zoneId,
    listorder,
    likehood,
    used
  ];

  static const String id = 'id';
  static const String workId = 'work_id';
  static const String workcode = 'workcode';
  static const String zoneId = 'zone_id';
  static const String likehood = 'likehood';
  static const String used = 'used';
  static const String listorder = 'list_order';
}

class HistoryOrder {
  HistoryOrder(
      {this.id,
        required this.workId,
        this.workcode,
        required this.zoneId,
        required this.listorder,
        this.likehood,
        this.used
      });

  HistoryOrder copy({
    int? id,
  }) =>
      HistoryOrder(
          id: id ?? this.id,
          workId: workId,
          workcode: workcode,
          zoneId: zoneId,
          listorder: listorder,
          likehood: likehood,
          used: used
      );

  // ignore: sort_constructors_first
  HistoryOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workId = json['work_id'] ?? 0;
    workcode = json['workcode'];
    zoneId = json['zone_id'] ?? 0;
    likehood = json['likehood'] is int ? json['likehood'].toDouble() : json['likehood'];
    used = json['used'] is int ? json['used'] == 1 ? true : false : json['used'];
    if (json['list_order'] != null) {
      var listOrder = jsonDecode(json['list_order']);
      listorder = [];
      listOrder.forEach((json) {
        listorder?.add(WorkOrder.fromJson(json));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['work_id'] = workId;
    data['workcode'] = workcode;
    data['zone_id'] = zoneId;
    data['likehood'] = likehood;
    data['used'] = used is bool ? used == true ? 1 : 0 : used;
    data['list_order'] = jsonEncode(listorder);
    return data;
  }

  int? id;
  int? workId;
  String? workcode;
  int? zoneId;
  double? likehood;
  bool? used;
  List<WorkOrder>? listorder;
}

class WorkOrder {
  WorkOrder({
    required this.id,
    required this.customer,
    this.address,
    this.latitude,
    this.longitude,
    this.geometry,
    required this.order});

  WorkOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customer = json['customer'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    geometry = json['geometry'];
    distance = json['distance'];
    duration = json['duration'];
    order = json['order'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['customer'] = customer;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['geometry'] = geometry;
    data['distance'] = distance;
    data['order'] = order;
    return data;
  }

  int? id;
  String? customer;
  String? address;
  String? latitude;
  String? longitude;
  String? geometry;
  String? distance;
  String? duration;
  int? order;
}
