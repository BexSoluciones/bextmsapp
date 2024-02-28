import 'dart:async';

typedef DialogShowHandler<T> = Future<T> Function();

class DialogController {
  late DialogShowHandler _showDialog;
  late Function _closeDialog;
  Completer? _dialogCompleter;

  /// Registers the showing and closing functions
  void configureDialog({
    required DialogShowHandler show,
    required Function close,
  }) {
    if (_dialogCompleter != null && !_dialogCompleter!.isCompleted) {
      _closeDialog();
    }
    _showDialog = show;
    _closeDialog = close;
  }

  Future<T?> show<T>() {
    final completer = Completer<T>();

    _dialogCompleter = completer;

    _showDialog().then((value) {
      if (completer.isCompleted) return;
      completer.complete(value);
    });

    return completer.future;
  }

  void close<T>([T? value]) {
    if (_dialogCompleter?.isCompleted ?? true) return;

    _dialogCompleter?.complete(value);
    _closeDialog();
    _dialogCompleter = null;
  }
}