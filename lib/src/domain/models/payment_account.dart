import 'package:equatable/equatable.dart';
import 'package:validators/validators.dart';

import 'account.dart';

class PaymentAccount extends Equatable {
  final Account? value;
  final String errorMessage;
  final bool hasError;

  const PaymentAccount({
    required this.value,
    required this.errorMessage,
    required this.hasError,
  });

  factory PaymentAccount.create(Account? value) {
    if (value == null) {
      return PaymentAccount(
          value: value, errorMessage: 'Cuenta inválida', hasError: true);
    }

    return PaymentAccount(value: value, errorMessage: '', hasError: false);
  }

  @override
  List<Object?> get props => [value, errorMessage, hasError];

  static const empty =
      PaymentAccount(value: null, errorMessage: '', hasError: false);
}
