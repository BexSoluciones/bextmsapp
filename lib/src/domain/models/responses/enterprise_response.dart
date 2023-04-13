import 'package:equatable/equatable.dart';

import '../enterprise.dart';

class EnterpriseResponse extends Equatable {
  final Enterprise enterprise;

  const EnterpriseResponse({
    required this.enterprise,
  });

  factory EnterpriseResponse.fromMap(Map<String, dynamic> map) {
    return EnterpriseResponse(
      enterprise: Enterprise.fromMap(map),
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [enterprise];
}