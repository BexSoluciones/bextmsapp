import 'package:equatable/equatable.dart';

class RoutingResponse extends Equatable {
  final int workId;

  const RoutingResponse({
    required this.workId,
  });

  factory RoutingResponse.fromMap(Map<String, dynamic> map) {
    return RoutingResponse(
      workId: map['work_id'],
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [workId];

}