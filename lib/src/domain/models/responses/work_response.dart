import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../work.dart';

class WorkResponse extends Equatable {
  final List<Work> works;

  const WorkResponse({required this.works});

  factory WorkResponse.fromMap(Map<String, dynamic> map) {

    print(map);

    return WorkResponse(
        works: List<Work>.from(map['works'] != null
            ? map['works']
                .map<Work>((x) => Work.fromJson(x as Map<String, dynamic>))
            : jsonDecode(map['data'])['works']
                .map<Work>((x) => Work.fromJson(x as Map<String, dynamic>))));
  }

  WorkResponse.fromJson(Map<String, dynamic> json) : works = json['works'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['works'] = works;
    return data;
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [works];
}
