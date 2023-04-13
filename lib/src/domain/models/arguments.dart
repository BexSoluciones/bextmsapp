import 'work.dart';
import 'summary.dart';

class WorkArgument {
  WorkArgument({
    required this.work
  });

  final Work work;
}

class SummaryArgument {
  SummaryArgument(
      {
        this.origin,
        required this.work
      });

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

  InventoryArgument(
      { required this.work,
        required this.summaryId,
        required this.typeOfCharge,
        required this.orderNumber,
        required this.operativeCenter,
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
  String? codePlace;
  int? validate;
  String? expedition;
  List<Summary>? summaries;
  List<dynamic>? r;
}

class PackageArgument {
  PackageArgument(
      {required this.workId,
        required this.summaryId,
        required this.zoneId,
        required this.workcode,
        required this.type,
        required this.customer,
        required this.nit,
        required this.address,
        required this.typeOfCharge,
        this.contact,
        required this.orderNumber,
        required this.operativeCenter,
        this.codePlace,
        this.summaries,
        this.packing,
        this.idPacking,
        this.expedition,
        this.r,
      });

  final int workId;
  final int? zoneId;
  final int summaryId;
  final String workcode;
  final String type;
  final String operativeCenter;
  final String customer;
  final String nit;
  final String address;
  final String typeOfCharge;
  final String? contact;
  final String orderNumber;
  final String? codePlace;
  final String? idPacking;
  final String? packing;
  final String? expedition;
  final List<Summary>? summaries;
  final List<dynamic>? r;
}



