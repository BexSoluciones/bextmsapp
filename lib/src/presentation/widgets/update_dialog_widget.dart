import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';

//config
import '../../config/size.dart';

//widgets
import 'default_button_widget.dart';

class UpdateDialog {
  UpdateDialog({required this.skipUpdate, this.message});

  bool skipUpdate;
  String? message;

  void _launchApp() {
    LaunchReview.launch(
        androidAppId: 'com.bexsoluciones.bexdeliveries', iOSAppId: 'com.bexsoluciones.bexdeliveries');
  }

  Future<Object?> showVersionDialog(context) async {
    return await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Scaffold(
              body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¡Nueva versión disponible!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: getProportionateScreenHeight(32),
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    Image.asset('assets/images/upgrade.png',
                        height: 200, width: 200, alignment: Alignment.center),
                    SizedBox(height: getProportionateScreenHeight(5)),
                    Text('¡Hemos mejorado pensando en ti!',
                        style: TextStyle(
                            fontSize: getProportionateScreenHeight(18))),
                    SizedBox(height: getProportionateScreenHeight(10)),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Para mejorar la experiencia solemos actualizar la App. Cada actualización tiene mejoras de rendimiento e incluye nuevas funcionalidades',
                            style: TextStyle(
                                fontSize: getProportionateScreenHeight(18),
                                letterSpacing: 1.4))),
                    SizedBox(height: getProportionateScreenHeight(10)),
                    message != null
                        ? Align(
                        alignment: Alignment.centerLeft,
                        child: Text(message!,
                            style: TextStyle(
                                fontSize: getProportionateScreenHeight(18),
                                letterSpacing: 1.4)))
                        : Container(),
                    SizedBox(height: getProportionateScreenHeight(40)),
                    DefaultButton(
                        widget: Text('Actualizar a la nueva versión',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: getProportionateScreenHeight(20))),
                        press: () => _launchApp()),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    skipUpdate
                        ? DefaultButton(
                        color: Colors.grey,
                        widget: Text('Más tarde.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                getProportionateScreenHeight(20))),
                        press: () => Navigator.of(context).pop())
                        : Container()
                  ],
                ),
              ),
            ),
          );
        });
  }
}
