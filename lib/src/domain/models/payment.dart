class Payment {
  Payment({required this.method, required this.paid, this.id_account});

  Payment.fromJson(Map<String, dynamic> json) {
    method = json['method'];
    paid = json['paid'];
    id_account = json['id_account'];
  }

  Map<String, dynamic> toJson(){
    return {
      'method': method,
      'paid': paid,
      'id_account':id_account,
    };
  }

  late String method;
  late String paid;
  String? id_account;
}
