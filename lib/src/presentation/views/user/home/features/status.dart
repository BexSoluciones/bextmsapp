import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

//widgets
import '../../../../widgets/icon_wifi_widget.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({Key? key, required this.one}) : super(key: key);

  final GlobalKey one;


  @override
  Widget build(BuildContext context) {
    return Showcase(
        key: one,
        disableMovingAnimation: true,
        title: 'Conexion!',
        description: 'Conoce en todo momento si estas en linea o no 😁',
        child: const IconConnection());
  }
}
