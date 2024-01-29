import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../reason.dart';

class ReasonResponse extends Equatable {
  final List<Reason> reasons;

  const ReasonResponse({required this.reasons});

  factory ReasonResponse.fromMap(Map<String, dynamic> map) {
    print(map);

    return ReasonResponse(
        reasons: List<Reason>.from(map['works'] != null
            ? map['works']
                .map<Reason>((x) => Reason.fromJson(x as Map<String, dynamic>))
            : jsonDecode(map['data'])['reasons'].map<Reason>(
                (x) => Reason.fromJson(x as Map<String, dynamic>))));
  }

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['reasons'] = reasons;
    return data;
  }

  @override
  List<Object> get props => [reasons];
}
