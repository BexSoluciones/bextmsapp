import 'package:flutter/material.dart';

//features
import './features/list_view.dart';
import './features/single_image.dart';

class QrView extends StatefulWidget {
  final String? codeQr;

  const QrView({Key? key, this.codeQr}) : super(key: key);

  @override
  State<QrView> createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Código QR'),
        ),
        body: widget.codeQr != null
            ? SingleImage(qr: widget.codeQr!)
            : const ListViewQr());
  }
}
