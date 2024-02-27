import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/constants/colors.dart';

errorGpsAlertDialog(
    {required completer,
    required BuildContext context,
    required String error,
    required IconData iconData,
    required String buttonText,
    required var onTap}) {
  if (Platform.isAndroid) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          if (!completer.isCompleted) {
            completer.complete(context);
          }
          ThemeData theme = Theme.of(context);
          return PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Activa la ubicación',
                        style: TextStyle(color: Colors.grey, fontSize: 26),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SvgPicture.asset('assets/icons/pin.svg',
                          height: 100, width: 100),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          textAlign: TextAlign.center,
                          "Necesitamos saber tu ubicacion,\n activa tu GPS para continuar disfrutando de la APP.",
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: onTap,
                        child: Container(
                          width: 180,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kPrimaryColor),
                          child: const Center(
                            child: Text(
                              'Activar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ]),
              ),
            ),
          );
        });
  } else {
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      iconData,
                      color: Colors.red.shade900,
                      size: 40,
                    ),
                  ),
                  const Text("Oh no!\n something went wrong."),
                ],
              ),
              content: Column(
                children: [
                  const Text(
                    textAlign: TextAlign.center,
                    "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    error,
                    style: TextStyle(
                      color: Colors.red.shade900,
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text(buttonText),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }
}
