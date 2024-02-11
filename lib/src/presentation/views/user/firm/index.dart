import 'package:flutter/material.dart';
//utils
import '../../../../utils/constants/colors.dart';
//widgets
import '../../../widgets/painter_widget.dart';

class FirmView extends StatefulWidget {
  const FirmView({super.key, required this.orderNumber});

  @override
  FirmViewState createState() => FirmViewState();

  final String orderNumber;
}

class FirmViewState extends State<FirmView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
            leading: null,
          ),
          backgroundColor: Colors.white,
          body: TouchControl(
              width: width, height: height, orderNumber: widget.orderNumber),
        ));
  }
}
