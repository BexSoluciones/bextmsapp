import 'package:bexdeliveries/src/domain/models/different.dart';
import 'package:bexdeliveries/src/domain/models/list_order.dart';
import 'package:equatable/equatable.dart';

import '../work.dart';

class PredictionResponse extends Equatable {
  final int id;
  final double likelihood;
  final int workId;
  final int zoneId;
  final String workcode;
  final List<ListOrder> listOrders;
  final List<Work> works;
  final List<Different> differences;
  final bool used;

  const PredictionResponse({
    required this.id,
    required this.likelihood,
    required this.workId,
    required this.zoneId,
    required this.workcode,
    required this.listOrders,
    required this.works,
    required this.differences,
    required this.used,
  });

  factory PredictionResponse.fromMap(Map<String, dynamic> map) {
    return PredictionResponse(
      id: map['id'],
      likelihood: map['likelihood'],
      workId: map['work_id'],
      zoneId: map['zone_id'],
      workcode: map['workcode'],
      listOrders: map['list_orders'],
      works: map['works'],
      differences: map['differents'],
      used: map['used'],
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        id,
        likelihood,
        workId,
        zoneId,
        workcode,
        listOrders,
        works,
        differences,
        used
      ];
}
