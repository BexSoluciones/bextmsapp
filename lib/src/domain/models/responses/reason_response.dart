import 'package:equatable/equatable.dart';

import '../reason.dart';

class ReasonResponse extends Equatable {
  final List<Reason> reasons;

  const ReasonResponse({
    required this.reasons
  });

  factory ReasonResponse.fromMap(Map<String, dynamic> map) {
    return ReasonResponse(
      reasons: List<Reason>.from(
        map['works'].map<Reason>(
              (x) => Reason.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [reasons];
}
