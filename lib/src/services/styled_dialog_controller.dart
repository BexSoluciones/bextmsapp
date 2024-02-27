import 'dialog_controller.dart';

enum Status { loading, error, success, iddle }

class StyledDialogController<S> {
  Map<String, DialogShowHandler> _styleBuilders = {};

  S? visibleDialogStyle;

  final DialogController _dialogController = DialogController();

  void registerDialogOf(
      {required S style, required DialogShowHandler builder}) {
    final styleIdentifier = style.toString();
    _styleBuilders[styleIdentifier] = builder;
  }

  Future<T?> showDialogWithStyle<T>(
    S style, {
    required Function closingFunction,
  }) {
    visibleDialogStyle = style;
    final styleIdentifier = style.toString();
    final builder = _styleBuilders[styleIdentifier];

    if (builder == null) return Future.value(null);

    _dialogController.configureDialog(
      show: builder,
      close: closingFunction,
    );
    return _dialogController.show();
  }

  void closeVisibleDialog<T>([T? value]) {
    visibleDialogStyle = null;
    _dialogController.close(value);
  }
}
