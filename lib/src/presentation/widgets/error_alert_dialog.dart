
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import '../../utils/constants/colors.dart';

errorGpsAlertDialog(
    {required BuildContext context,
      required String error,
      required IconData iconData,
      required String buttonText,
      required var onTap}) {
  if (Platform.isAndroid) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Size size = MediaQuery.of(context).size;
          ThemeData theme = Theme.of(context);
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
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
                      Lottie.asset(
                          'assets/animations/137331-map-marker-gps-city-navigation-location-sign.json',
                          height: 100,
                          width: 100),
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
                      /*  Text(
                        textAlign: TextAlign.center,
                        error,
                        style: TextStyle(
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(6
                        height: 20,
                      ), */
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
                      /*                     InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            height: 40,
                            width: size.width * 0.5,
                            decoration: BoxDecoration(
                              //  color: activeColor,
                              border: Border.all(color: theme.hoverColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                buttonText,
                                style: TextStyle(
                                  color: theme.hoverColor,
                                  fontSize: 14,
                                ),
                              ),
                            )),
                      ) */
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
