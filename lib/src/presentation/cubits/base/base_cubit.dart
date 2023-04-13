import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseCubit<S, T> extends Cubit<S> {
  BaseCubit(S initialState, this.data) : super(initialState);

  T data;

  @protected
  T get getData => data;

  set setData(data) => data = data;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  @protected
  Future<void> run(Future<void> Function() process) async {
    if (!_isBusy) {
      _isBusy = true;
      await process();
      _isBusy = false;
    }
  }
}