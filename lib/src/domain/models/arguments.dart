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
    required this.summary,
    this.total,
    this.summaries,
    this.r,
  });

  final Work work;
  final Summary summary;
  double? total;
  List<Summary>? summaries;
  List<dynamic>? r;
}

class PackageArgument {
  PackageArgument({
    required this.work,
    required this.summary,
    this.summaries,
  });

  final Work work;
  final Summary summary;
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
