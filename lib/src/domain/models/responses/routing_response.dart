import 'package:equatable/equatable.dart';
import '../work.dart';

class RoutingResponse extends Equatable {
  final List<Work> works;

  const RoutingResponse({
    required this.works,
  });

  factory RoutingResponse.fromMap(Map<String, dynamic> map) {
    return RoutingResponse(
      works: map['works'],
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [works];

}