class ListOrder {
  ListOrder({
    required this.id,
    required this.order,
    required this.address,
    required this.customer,
    this.distance,
    this.geometry,
    required this.latitude,
    required this.longitude,
    required this.codePlace,
    required this.numberCustomer,
  });

  int id;
  int order;
  String address;
  String customer;
  dynamic distance;
  dynamic geometry;
  String latitude;
  String longitude;
  String codePlace;
  String numberCustomer;

  factory ListOrder.fromJson(Map<String, dynamic> json) => ListOrder(
    id: json['id'],
    order: json['order'],
    address: json['address'],
    customer: json['customer'],
    distance: json['distance'],
    geometry: json['geometry'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    codePlace: json['code_place'],
    numberCustomer: json['number_customer'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'order': order,
    'address': address,
    'customer': customer,
    'distance': distance,
    'geometry': geometry,
    'latitude': latitude,
    'longitude': longitude,
    'code_place': codePlace,
    'number_customer': numberCustomer,
  };
}
