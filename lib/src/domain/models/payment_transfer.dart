import 'package:equatable/equatable.dart';

class PaymentTransfer extends Equatable {
  final String value;
  final String errorMessage;
  final bool hasError;

  const PaymentTransfer({
    required this.value,
    required this.errorMessage,
    required this.hasError,
  });

  factory PaymentTransfer.create(String value) {
    if (value.startsWith('.') || value.endsWith('.')) {
      return PaymentTransfer(
          value: value, errorMessage: 'valor no válido', hasError: true);
    }

    if (value.contains(',')) {
      return PaymentTransfer(
          value: value, errorMessage: 'no debe contener comas', hasError: true);
    }
    return PaymentTransfer(value: value, errorMessage: '', hasError: false);
  }

  @override
  List<Object?> get props => [value, errorMessage, hasError];

  static const empty =
      PaymentTransfer(value: '', errorMessage: '', hasError: false);
}
