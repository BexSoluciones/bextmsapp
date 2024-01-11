const String tableErrors = 'errors';

class ErrorFields {
  static final List<String> values = [
    id,
    errorMessage,
    stackTrace,
    createdAt,
  ];

  static const String id = 'id';
  static const String errorMessage = 'errorMessage';
  static const String stackTrace = 'stackTrace';
  static const String createdAt = 'created_at';
}

class Error {
  Error(
      {this.id,
      required this.errorMessage,
      required this.stackTrace,
      required this.createdAt});

  Error copy({
    int? id,
  }) =>
      Error(
          id: id ?? this.id,
          errorMessage: errorMessage,
          stackTrace: stackTrace,
          createdAt: createdAt);

  Error.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    errorMessage = json['errorMessage'];
    stackTrace = json['stackTrace'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorMessage'] = errorMessage;
    data['stackTrace'] = stackTrace;
    data['created_at'] = createdAt;
    return data;
  }

  int? id;
  String? errorMessage;
  String? stackTrace;
  String? createdAt;
}
