class Payment {
  Payment({required this.method, required this.paid, this.accountId});

  Payment.fromJson(Map<String, dynamic> json) {
    method = json['method'];
    paid = json['paid'];
    accountId = json['id_account'];
  }

  Map<String, dynamic> toJson(){
    return {
      'method': method,
      'paid': paid,
      'id_account':accountId,
    };
  }

  late String method;
  late String paid;
  String? accountId;
}
