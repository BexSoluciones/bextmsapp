import 'package:equatable/equatable.dart';

class HistoryOrderSavedResponse extends Equatable {
  final int workId;

  const HistoryOrderSavedResponse({
    required this.workId,
  });

  factory HistoryOrderSavedResponse.fromMap(Map<String, dynamic> map) {
    return HistoryOrderSavedResponse(
      workId: map['work_id'],
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [workId];

}