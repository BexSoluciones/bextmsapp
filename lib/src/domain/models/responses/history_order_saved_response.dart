import 'package:equatable/equatable.dart';

class HistoryOrderSavedResponse extends Equatable {
  final int status;
  final String message;

  const HistoryOrderSavedResponse({
    required this.status,
    required this.message,
  });

  factory HistoryOrderSavedResponse.fromMap(Map<String, dynamic> map) {
    return HistoryOrderSavedResponse(
      status: map['status'],
      message: map['message'],
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [status, message];

}