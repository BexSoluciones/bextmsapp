import 'package:equatable/equatable.dart';

class HistoryOrderUpdatedResponse extends Equatable {
  final int workId;

  const HistoryOrderUpdatedResponse({
    required this.workId,
  });

  factory HistoryOrderUpdatedResponse.fromMap(Map<String, dynamic> map) {
    return HistoryOrderUpdatedResponse(
      workId: map['work_id'],
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [workId];

}