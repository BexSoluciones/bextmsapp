import 'package:equatable/equatable.dart';

class LogoutResponse extends Equatable {
  final String message;

  const LogoutResponse({
    required this.message,
  });

  factory LogoutResponse.fromMap(Map<String, dynamic> map) {
    return LogoutResponse(
      message: map['message'],
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [message];
}