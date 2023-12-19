class Payment {
  Payment(
      {required this.method, required this.paid, this.accountId, this.date});

  Payment.fromJson(Map<String, dynamic> json) {
    method = json['method'];
    paid = json['paid'];
    accountId = json['id_account'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'paid': paid,
      'id_account': accountId,
      'date': date,
    };
  }

  late String method;
  late String paid;
  String? accountId;
  String? date;
}
