import 'package:equatable/equatable.dart';

class PaymentMultiTransfer extends Equatable {
  final String value;
  final String errorMessage;
  final bool hasError;

  const PaymentMultiTransfer({
    required this.value,
    required this.errorMessage,
    required this.hasError,
  });

  factory PaymentMultiTransfer.create(String value) {
    if (value.startsWith('.') || value.endsWith('.')) {
      return PaymentMultiTransfer(
          value: value, errorMessage: 'valor no válido', hasError: true);
    }

    if (value.contains(',')) {
      return PaymentMultiTransfer(
          value: value, errorMessage: 'no debe contener comas', hasError: true);
    }
    return PaymentMultiTransfer(
        value: value, errorMessage: '', hasError: false);
  }

  @override
  List<Object?> get props => [value, errorMessage, hasError];

  static const empty =
      PaymentMultiTransfer(value: '', errorMessage: '', hasError: false);
}
