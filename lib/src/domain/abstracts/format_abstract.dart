import 'package:intl/intl.dart';

class FormatNumber {
  final NumberFormat formatter = NumberFormat('#,##0.00', 'es_CO');
  final String currency = '  ${NumberFormat.compactSimpleCurrency(locale: 'en').currencySymbol}';
}

abstract class FormatDate {
  String now() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  String date(DateTime? date) {
    return DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());
  }
}
