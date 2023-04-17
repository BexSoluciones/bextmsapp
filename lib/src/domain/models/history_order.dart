import 'dart:convert';
import 'work.dart';
import 'different.dart';
import 'list_order.dart';

const String tableHistoryOrders = 'history_orders';

class HistoryOrderFields {
  static final List<String> values = [
    id,
    workId,
    workcode,
    zoneId,
    listOrder,
    likelihood,
    used,
    works,
    different
  ];

  static const String id = 'id';
  static const String workId = 'work_id';
  static const String workcode = 'workcode';
  static const String zoneId = 'zone_id';
  static const String likelihood = 'likelihood';
  static const String used = 'used';
  static const String listOrder = 'list_order';
  static const String works = 'works';
  static const String different = 'different';
}

class HistoryOrder {
  HistoryOrder(
      {this.id,
        this.workcode,
        required this.workId,
        required this.zoneId,
        required this.listOrder,
        required this.works,
        required this.different,
        this.likelihood,
        this.used});

  HistoryOrder copy({
    int? id,
  }) =>
      HistoryOrder(
          id: id ?? this.id,
          workId: workId,
          workcode: workcode,
          zoneId: zoneId,
          listOrder: listOrder,
          works: works,
          different: different,
          likelihood: likelihood,
          used: used);

  // ignore: sort_constructors_first
  HistoryOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workId = json['work_id'] ?? 0;
    workcode = json['workcode'];
    zoneId = json['zone_id'] ?? 0;
    likelihood = json['likelihood'] is int
        ? json['likelihood'].toDouble()
        : json['likelihood'];
    used = json['used'] is int
        ? json['used'] == 1
        ? true
        : false
        : json['used'];
    if (json['list_order'] != null) {
      var listOrder = jsonDecode(json['list_order']);
      listOrder = [];
      listOrder.forEach((json) {
        listOrder.add(ListOrder.fromJson(json));
      });
    }

    if (json['works'] != null) {
      var worksD = jsonDecode(json['works']);
      works = [];
      worksD.forEach((json) {
        works.add(Work.fromJson(json));
      });
    }

    if (json['different'] != null) {
      var differentD = jsonDecode(json['different']);
      different = [];
      differentD.forEach((json) {
        different.add(Different.fromJson(json));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['work_id'] = workId;
    data['workcode'] = workcode;
    data['zone_id'] = zoneId;
    data['likelihood'] = likelihood;
    data['used'] = used is bool
        ? used == true
        ? 1
        : 0
        : used;
    data['list_order'] = jsonEncode(listOrder);
    data['works'] = jsonEncode(works);
    data['different'] = jsonEncode(different);
    return data;
  }

  int? id;
  late int workId;
  String? workcode;
  int? zoneId;
  double? likelihood;
  bool? used;
  late List<ListOrder> listOrder;
  late List<Work> works;
  late List<Different> different;
}