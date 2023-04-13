import 'package:equatable/equatable.dart';

import '../enterprise_config.dart';

class EnterpriseConfigResponse extends Equatable {
  final EnterpriseConfig enterpriseConfig;

  const EnterpriseConfigResponse({
    required this.enterpriseConfig,
  });

  factory EnterpriseConfigResponse.fromMap(Map<String, dynamic> map) {
    return EnterpriseConfigResponse(
      enterpriseConfig: EnterpriseConfig.fromMap(map),
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [enterpriseConfig];
}