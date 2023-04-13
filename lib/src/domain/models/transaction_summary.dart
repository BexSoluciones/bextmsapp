const String tableTransactionSummaries = 'transaction_summaries';

class TransactionSummaryFields {
  static final List<String> values = [
    id,
    transactionId,
    summaryId,
    orderNumber,
    workId,
    numItems,
    productName,
    codmotvis,
    reason,
    createdAt,
    updatedAt
  ];

  static const String id = 'id';
  static const String transactionId = 'transaction_id';
  static const String summaryId = 'summary_id';
  static const String orderNumber = 'order_number';
  static const String workId = 'work_id';
  static const String numItems = 'num_items';
  static const String productName = 'product_name';
  static const String codmotvis = 'codmotvis';
  static const String reason = 'reason';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class TransactionSummary {
  TransactionSummary(
      {this.id,
        this.transactionId,
        required this.summaryId,
        this.orderNumber,
        this.workId,
        required this.numItems,
        required this.productName,
        this.codmotvis,
        this.reason, this.createdAt,
        this.updatedAt});

  TransactionSummary copy({
    int? id,
  }) =>
      TransactionSummary(
          id: id ?? this.id,
          transactionId: transactionId,
          summaryId: summaryId,
          orderNumber: orderNumber,
          workId: workId,
          numItems: numItems,
          productName: productName,
          codmotvis: codmotvis,
          reason: reason,
          createdAt: createdAt,
          updatedAt: updatedAt);

  int? id;
  int? transactionId;
  int? summaryId;
  String? orderNumber;
  int? workId;
  String? numItems;
  String? productName;
  String? codmotvis;
  String? reason;
  String? createdAt;
  String? updatedAt;

  // ignore: sort_constructors_first
  TransactionSummary.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionId = json['transaction_id'];
    summaryId = json['summary_id'];
    orderNumber = json['order_number'];
    workId = json['work_id'];
    numItems = json['num_items'] is int ? json['num_items'].toString() : json['num_items'];
    productName = json['product_name'];
    codmotvis = json['codmotvis'];
    reason = json['reason'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['transaction_id'] = transactionId;
    data['summary_id'] = summaryId;
    data['order_number'] = orderNumber;
    data['work_id'] = workId;
    data['num_items'] = numItems;
    data['product_name'] = productName;
    data['codmotvis'] = codmotvis;
    data['reason'] = reason;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
