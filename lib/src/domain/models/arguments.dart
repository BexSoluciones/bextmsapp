import 'work.dart';
import 'summary.dart';
import 'different.dart';

class WorkArgument {
  WorkArgument({required this.work});

  final Work work;
}

class SummaryArgument {
  SummaryArgument({this.origin, required this.work});

  final String? origin;
  final Work work;
}

class SummaryNavigationArgument {
  SummaryNavigationArgument({
    required this.work,
  });

  final Work work;
}

class InventoryArgument {
  InventoryArgument({
    required this.work,
    required this.summaryId,
    required this.typeOfCharge,
    required this.orderNumber,
    required this.operativeCenter,
    this.total,
    this.expedition,
    this.codePlace,
    this.summaries,
    this.validate,
    this.r,
  });

  final Work work;
  final int summaryId;
  final String typeOfCharge;
  final String operativeCenter;
  final String orderNumber;
  double? total;
  String? codePlace;
  int? validate;
  String? expedition;
  List<Summary>? summaries;
  List<dynamic>? r;
}

class PackageArgument {
  PackageArgument({
    required this.work,
    required this.summaryId,
    required this.typeOfCharge,
    required this.orderNumber,
    required this.operativeCenter,
    this.codePlace,
    this.summaries,
    this.packing,
    this.idPacking,
    this.expedition,
  });

  final Work work;
  final int summaryId;
  final String operativeCenter;
  final String typeOfCharge;
  final String orderNumber;
  final String? codePlace;
  final String? idPacking;
  final String? packing;
  final String? expedition;
  final List<Summary>? summaries;
}

class HistoryArgument {
  HistoryArgument({
    required this.work,
    required this.likelihood,
    required this.differents,
  });

  final Work work;
  final double likelihood;
  final List<Different> differents;
}