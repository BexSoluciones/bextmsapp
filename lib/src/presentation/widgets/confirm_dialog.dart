import 'package:flutter/material.dart';
import 'circular_progress.dart';

class ConfirmDialog extends StatefulWidget {
  ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });
  final String title;
  final String message;
  final Function onConfirm;

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        saving ? null : Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  Visibility(
                    visible: !saving,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          saving = true;
                        });
                        await widget.onConfirm();
                        //Navigator.of(context).pop();
                      },
                      child: const Text('Guardar'),
                    ),
                  ),
                  Visibility(
                    visible: saving,
                    child: MyCircularProgressIndicator(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
