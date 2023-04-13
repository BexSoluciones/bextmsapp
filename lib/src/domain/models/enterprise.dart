import 'package:equatable/equatable.dart';

class Enterprise extends Equatable {

  final int? id;
  final String? name;
  final String? logo;
  final String? nit;
  final String? phone;

  const Enterprise({
    this.id,
    required this.name,
    this.logo,
    this.nit,
    this.phone
  });

  factory Enterprise.fromMap(Map<String, dynamic> map) {
    return Enterprise(
      id : map['id'] != null ? map['id'] as int : null,
      name : map['name'] != null ? map['name'] as String : null,
      logo : map['logo'] != null ? map['logo'] as String : null,
      nit : map['nit'] != null ? map['nit'] as String : null,
      phone : map['phone'] != null ? map['phone'] as String : null,
    );
  }

  Map toMap() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'nit': nit,
      'phone': phone
    };
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [id, name, logo, nit, phone];
}
