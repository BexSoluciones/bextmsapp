const String tableWarehouses = 'warehouses';

class WarehouseFields {
  static final List<String> values = [
    id,
    name,
    latitude,
    longitude,
    description,
    createdAt,
    updatedAt,
    codeWarehouse,
    principal
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String codeWarehouse = 'code_warehouse';
  static const String principal = 'principal';
  static const String description = 'description';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class Warehouse {
  Warehouse(
      {this.id,
      this.name,
      this.latitude,
      this.longitude,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.codeWarehouse,
      this.principal});

  Warehouse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    codeWarehouse = json['code_warehouse'];
    principal = json['principal'] is String ? int.parse(json['principal']) : json['principal'];
  }

  late int? id;
  late String? name;
  late String? latitude;
  late String? longitude;
  late String? description;
  late String? createdAt;
  late String? updatedAt;
  late String? codeWarehouse;
  late int? principal;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['code_warehouse'] = codeWarehouse;
    data['principal'] = principal;
    return data;
  }
}
