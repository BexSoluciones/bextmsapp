import 'package:equatable/equatable.dart';

class StatusResponse extends Equatable {
  final String message;

  const StatusResponse({
    required this.message,
  });

  factory StatusResponse.fromMap(Map<String, dynamic> map) {
    return StatusResponse(
      message: map['message'],
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [message];
}