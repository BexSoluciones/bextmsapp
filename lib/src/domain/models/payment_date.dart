import 'package:equatable/equatable.dart';

class PaymentDate extends Equatable {
  final String value;
  final String errorMessage;
  final bool hasError;

  const PaymentDate({
    required this.value,
    required this.errorMessage,
    required this.hasError,
  });

  factory PaymentDate.create(String value) {

    return PaymentDate(value: value, errorMessage: '', hasError: false);
  }

  @override
  List<Object?> get props => [value, errorMessage, hasError];

  static const empty =
      PaymentDate(value: '', errorMessage: '', hasError: false);
}
