class TransactionValidate {

  TransactionValidate({required this.workId, required this.countSummaries, required this.countTransactions});

  factory TransactionValidate.fromJson(Map<String, dynamic> json) => TransactionValidate(
      workId: json['work_id'],
      countSummaries: json['countSummaries'],
      countTransactions: json['countTransactions']
  );

  Map<String, dynamic> toJson() => {
    'work_id': workId,
    'countSummaries': countSummaries,
    'countTransactions' : countTransactions
  };

  late int workId, countSummaries, countTransactions;
}
