import 'package:flutter/material.dart';

import 'circular_progress.dart';

class CustomConfirmDialog extends StatefulWidget {
  CustomConfirmDialog(
      {super.key,
      required this.title,
      required this.message,
      required this.onConfirm,
      required this.cancelButton,
      required this.buttonText});
  final String title;
  final String message;
  final Function onConfirm;
  final bool? cancelButton;
  final String buttonText;

  @override
  State<CustomConfirmDialog> createState() => _CustomConfirmDialogState();
}

class _CustomConfirmDialogState extends State<CustomConfirmDialog> {
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
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (widget.cancelButton == true)
                      ? TextButton(
                          onPressed: () =>
                              saving ? null : Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        )
                      : Container(),
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
                      child: Text(widget.buttonText),
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
