import 'package:equatable/equatable.dart';

class PaymentEfecty extends Equatable {
  final String value;
  final String errorMessage;
  final bool hasError;

  const PaymentEfecty({
    required this.value,
    required this.errorMessage,
    required this.hasError,
  });

  factory PaymentEfecty.create(String value) {
    if (value.startsWith('.') || value.endsWith('.')) {
      return PaymentEfecty(
          value: value, errorMessage: 'valor no válido', hasError: true);
    }

    if (value.contains(',')) {
      return PaymentEfecty(
          value: value, errorMessage: 'no debe contener comas', hasError: true);
    }

    return PaymentEfecty(value: value, errorMessage: '', hasError: false);
  }

  @override
  List<Object?> get props => [value, errorMessage, hasError];

  static const empty =
      PaymentEfecty(value: '', errorMessage: '', hasError: false);
}
