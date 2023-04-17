class Different {
  Different({
    required this.id,
    required this.order,
    required this.address,
    required this.customer,
    required this.numberCustomer,
    required this.codePlace,
  });

  int id;
  int order;
  String address;
  String customer;
  String numberCustomer;
  String codePlace;

  factory Different.fromJson(Map<String, dynamic> json) => Different(
    id: json['id'],
    order: json['order'],
    address: json['address'],
    customer: json['customer'],
    numberCustomer: json['number_customer'],
    codePlace: json['code_place'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'order': order,
    'address': address,
    'customer': customer,
    'number_customer': numberCustomer,
    'code_place': codePlace,
  };
}