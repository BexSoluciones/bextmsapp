import 'package:intl/intl.dart';

abstract class FormatNumber {
  final NumberFormat formatter = NumberFormat('#,##0.00', 'es_CO');
}

abstract class FormatDate {

  String now(){
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }
}