import 'package:flutter/material.dart';
import 'dart:math';
import 'summary.dart';

const String tableWorks = 'works';

class WorkFields {
  static final List<String> values = [
    id,
    workcode,
    numberCompany,
    numberTransporter,
    nameTransporter,
    nameuser,
    date,
    datedelivery,
    tracking,
    amountPieces,
    numberCustomer,
    codePlace,
    customer,
    address,
    cellphone,
    email,
    city,
    latitude,
    longitude,
    observations,
    order,
    color,
    active,
    isCalculated,
    status,
    duration,
    distance,
    geometry,
    zoneId,
    warehouseId,
    createdAt,
    updatedAt
  ];

  static const String id = 'id';
  static const String workcode = 'workcode';
  static const String numberCompany = 'number_company';
  static const String numberTransporter = 'number_transporter';
  static const String nameTransporter = 'name_transporter';
  static const String nameuser = 'nameuser';
  static const String date = 'date';
  static const String datedelivery = 'datedelivery';
  static const String tracking = 'tracking';
  static const String amountPieces = 'amount_pieces';
  static const String numberCustomer = 'number_customer';
  static const String type = 'type';
  static const String codePlace = 'code_place';
  static const String customer = 'customer';
  static const String address = 'address';
  static const String cellphone = 'cellphone';
  static const String email = 'email';
  static const String city = 'city';
  static const String state = 'state';
  static const String postalcode = 'postalcode';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String observations = 'observations';
  static const String order = '`order`';
  static const String color = 'color';
  static const String status = 'status';
  static const String isCalculated = 'is_calculated';
  static const String active = 'active';
  static const String duration = 'duration';
  static const String distance = 'distance';
  static const String geometry = 'geometry';
  static const String zoneId = 'zone_id';
  static const String warehouseId = 'warehouse_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class Work {
  Work(
      {required this.id,
        required this.workcode,
        this.numberCompany,
        this.numberTransporter,
        required this.nameTransporter,
        this.nameuser,
        required this.date,
        this.datedelivery,
        this.tracking,
        this.amountPieces,
        required this.numberCustomer,
        required this.type,
        this.codePlace,
        required this.customer,
        required this.address,
        this.cellphone,
        this.email,
        this.city,
        this.state,
        this.postalcode,
        this.latitude,
        this.longitude,
        this.observations,
        this.count,
        this.isCalculated,
        this.active,
        this.order,
        this.color,
        this.status,
        this.distance,
        this.duration,
        this.geometry,
        this.right,
        this.left,
        this.hasCompleted,
        this.createdAt,
        this.updatedAt,
        this.summaries,
        this.warehouseId,
        this.zoneId
      });

  Work copy({
    int? id,
  }) =>
      Work(
          id: id ?? this.id,
          workcode: workcode,
          numberCompany: numberCompany ?? numberCompany,
          numberTransporter: numberTransporter ?? numberTransporter,
          nameTransporter: nameTransporter,
          nameuser: nameuser ?? nameuser,
          date: date,
          datedelivery: datedelivery ?? datedelivery,
          tracking: tracking ?? tracking,
          amountPieces: amountPieces ?? amountPieces,
          numberCustomer: numberCustomer,
          type: type,
          codePlace: codePlace ?? codePlace,
          customer: customer,
          address: address,
          cellphone: cellphone ?? cellphone,
          email: email ?? email,
          city: city ?? city,
          state: state ?? state,
          postalcode: postalcode ?? postalcode,
          latitude: latitude ?? latitude,
          longitude: longitude ?? longitude,
          observations: observations ?? observations,
          count: count ?? count,
          isCalculated: isCalculated,
          active: active,
          order: order ?? 999,
          status: status,
          color: color ?? Random().nextInt(Colors.primaries.length),
          distance: distance ?? distance,
          duration: duration ?? duration,
          createdAt: createdAt,
          updatedAt: updatedAt,
          right: right,
          left: left,
          summaries: summaries,
          warehouseId: warehouseId,
          zoneId: zoneId
      );

  int? id;
  String? workcode;
  String? numberCompany;
  String? numberTransporter;
  String? nameTransporter;
  String? nameuser;
  String? date;
  String? datedelivery;
  String? tracking;
  int? amountPieces;
  String? numberCustomer;
  String? type;
  String? codePlace;
  String? customer;
  String? address;
  String? cellphone;
  String? email;
  String? city;
  String? state;
  String? postalcode;
  String? latitude;
  String? longitude;
  String? observations;
  int? count;
  bool? isCalculated = false;
  bool? active = false;
  int? order;
  int? color;
  String? status;
  String? distance;
  String? duration;
  String? geometry;
  String? createdAt;
  String? updatedAt;
  int? right;
  int? left;
  int? zoneId;
  int? hasCompleted;
  List<Summary>? summaries;
  int? warehouseId;

  // ignore: sort_constructors_first
  Work.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workcode = json['workcode'];
    numberCompany = (json['number_company'] is int || json['number_customer'] is double) ? json['number_company'].toString()
        : json['number_company'];
    numberTransporter = json['number_transporter'];
    nameTransporter = json['name_transporter'];
    nameuser = json['nameuser'];
    date = json['date'];
    datedelivery = json['datedelivery'];
    tracking = json['tracking'];
    amountPieces = (json['amount_pieces'] is String)
        ? int.parse(json['amount_pieces'])
        : json['amount_pieces'];
    numberCustomer = json['number_customer'];
    type = json['type'];
    codePlace = json['code_place'];
    customer = json['customer'];
    address = json['address'];
    cellphone = (json['cellphone'] is int || json['cellphone'] is double)
        ? json['cellphone'].toString()
        : json['cellphone'];
    email = json['email'];
    city = json['city'];
    state = json['state'];
    postalcode = json['postalcode'];
    latitude = (json['latitude'] == null) ? '0' : json['latitude'];
    longitude = (json['longitude'] == null) ? '0' : json['longitude'];
    observations = json['observations'];
    count = json['count'] ?? 0;
    isCalculated = json['is_calculated'] == 1 ? true : false;
    active = json['active'] == 1 ? true : false;
    order = json['order'];
    color = json['color'];
    status = json['status'];
    distance = json['distance'];
    duration = json['duration'];
    geometry = json['geometry'];
    right = json['right'];
    left = json['left'];
    hasCompleted = json['has_completed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    zoneId = json['zone_id'];
    warehouseId = json['warehouse_id'];
    if(json['summaries'] != null){
      summaries =  json['summaries'].map<Summary>((e) => Summary.fromJson(e)).toList();
    }

  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['workcode'] = workcode;
    data['number_company'] = numberCompany;
    data['number_transporter'] = numberTransporter;
    data['name_transporter'] = nameTransporter;
    data['nameuser'] = nameuser;
    data['date'] = date;
    data['datedelivery'] = datedelivery;
    data['tracking'] = tracking;
    data['amount_pieces'] = amountPieces;
    data['number_customer'] = numberCustomer;
    data['type'] = type;
    data['code_place'] = codePlace;
    data['customer'] = customer;
    data['address'] = address;
    data['cellphone'] = cellphone;
    data['email'] = email;
    data['city'] = city;
    data['state'] = state;
    data['postalcode'] = postalcode;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['observations'] = observations;
    data['order'] = order;
    data['color'] = color;
    data['status'] = status;
    data['is_calculated'] = isCalculated! ? 1 : 0;
    data['active'] = active != null && active! ? 1 : 0;
    data['distance'] = distance;
    data['duration'] = duration;
    data['geometry'] = geometry;
    data['zone_id'] = zoneId;
    data['warehouse_id'] = warehouseId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}