import 'package:flutter/cupertino.dart';

const String tableReasons = 'reasons';

class ReasonFields {
  static final List<String> values = [
    id,
    codmotvis,
    nommotvis,
    gendetmotvis,
    tipocliente,
    firm,
    observation,
    photo,
    count,
    createdAt,
    updatedAt
  ];

  static const String id = 'id';
  static const String codmotvis = 'codmotvis';
  static const String nommotvis = 'nommotvis';
  static const String gendetmotvis = 'gendetmotvis';
  static const String tipocliente = 'tipocliente';
  static const String firm = 'firm';
  static const String observation = 'observation';
  static const String photo = 'photo';
  static const String count = 'count';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class Reason {
  Reason(
      {required this.id,
      required this.codmotvis,
      required this.nommotvis,
      required this.gendetmotvis,
      required this.tipocliente,
      this.firm,
      this.observation,
      this.photo,
      this.count,
      required this.createdAt,
      required this.updatedAt});

  Reason.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    codmotvis = json['codmotvis'];
    nommotvis = json['nommotvis'];
    gendetmotvis = json['gendetmotvis'];
    tipocliente = json['tipocliente'];
    firm = json['firm'];
    observation = json['observation'];
    photo = json['photo'];
    count = json['count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['codmotvis'] = codmotvis;
    data['nommotvis'] = nommotvis;
    data['gendetmotvis'] = gendetmotvis;
    data['tipocliente'] = tipocliente;
    data['firm'] = firm;
    data['observation'] = observation;
    data['photo'] = photo;
    data['count'] = count;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  late int id;
  late String codmotvis;
  late String nommotvis;
  late String gendetmotvis;
  late String tipocliente;
  int? firm;
  int? observation;
  int? photo;
  int? count;
  late String createdAt;
  late String updatedAt;

  static List<String> getSuggestions(List<Reason> reasons, String query) {
    var matches = <String>[];
    matches.addAll(reasons.map((e) => e.nommotvis));
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}

class ReasonProduct {
  ReasonProduct({
    required this.index,
    required this.controller,
    required this.summaryId,
    required this.nameItem,
  });

  late int index;
  late int summaryId;
  late String nameItem;
  late TextEditingController controller;
}
