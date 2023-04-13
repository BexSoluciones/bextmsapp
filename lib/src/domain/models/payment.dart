class Payment {
  Payment({required this.method, required this.paid});

  Payment.fromJson(Map<String, dynamic> json) {
    method = json['method'];
    paid = json['paid'];
  }

  Map<String, dynamic> toJson(){
    return {
      'method': method,
      'paid': paid,
    };
  }

  late String method;
  late String paid;
}
