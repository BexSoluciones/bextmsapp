import 'dart:convert';

abstract class DataState<T> {
  final T? data;
  final String? error;

  const DataState({this.data, this.error});

  DataState.fromJson(Map<String, dynamic> json)
      : data = json['data'],
        error = json['error'];

  Map<String, dynamic> toJson() {
    return {
      'data': jsonEncode(data),
      'error': error
    };
  }
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(String error) : super(error: error);
}

class DataNotSet<T> extends DataState<T> {
  const DataNotSet();
}