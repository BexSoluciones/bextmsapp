import 'package:equatable/equatable.dart';
import 'package:validators/validators.dart';

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
    if (isDate(value)) {
      return PaymentTransfer(
          value: value, errorMessage: 'fecha no válido', hasError: true);
    }

    return PaymentTransfer(value: value, errorMessage: '', hasError: false);
  }

  @override
  List<Object?> get props => [value, errorMessage, hasError];

  static const empty =
      PaymentTransfer(value: '', errorMessage: '', hasError: false);
}
