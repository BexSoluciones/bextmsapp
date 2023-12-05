import 'package:equatable/equatable.dart';

class PredictionResponse extends Equatable {
  final int id;
  final double likehood;
  final int workId;
  final int zoneId;
  final String workcode;
  final List listOrders;
  final List works;
  final List differents;
  final bool used;

  const PredictionResponse({
    required this.id,
    required this.likehood,
    required this.workId,
    required this.zoneId,
    required this.workcode,
    required this.listOrders,
    required this.works,
    required this.differents,
    required this.used,
  });

  factory PredictionResponse.fromMap(Map<String, dynamic> map) {
    return PredictionResponse(
      id: map['id'],
      likehood: map['likehood'],
      workId: map['work_id'],
      zoneId: map['zone_id'],
      workcode: map['workcode'],
      listOrders: map['list_orders'],
      works: map['works'],
      differents: map['differents'],
      used: map['used'],
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        id,
        likehood,
        workId,
        zoneId,
        workcode,
        listOrders,
        works,
        differents,
        used
      ];
}
