import 'package:equatable/equatable.dart';

class DatabaseResponse extends Equatable {
  final String message;
  final String error;

  const DatabaseResponse({
    required this.message,
    required this.error
  });

  factory DatabaseResponse.fromMap(Map<String, dynamic> map) {
    return DatabaseResponse(
      message: map['message'],
      error: map['error']
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [message, error];
}