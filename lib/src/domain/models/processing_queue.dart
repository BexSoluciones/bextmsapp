const String tableProcessingQueues = 'processing_queues';

class ProcessingQueueFields {
  static final List<String> values = [
    id,
    task,
    body,
    code,
    error
  ];

  static const String id = 'id';
  static const String body = 'body';
  static const String task = 'task';
  static const String code = 'code';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String error = '_error';
}

class ProcessingQueue {
  ProcessingQueue({
    this.id,
    required this.body,
    required this.task,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
    this.error,
  });

  ProcessingQueue.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    body = json['body'];
    task = json['task'];
    code = json['code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    error = json['_error'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['body'] = body;
    data['task'] = task;
    data['code'] = code;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['_error'] = error;
    return data;
  }

  late int? id;
  late String body;
  late String task;
  late String code;
  late String createdAt;
  late String updatedAt;
  String? error;
}
