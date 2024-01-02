import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

//utils
import '../../../../utils/constants/nums.dart';

//features
import './features/form.dart';

class NotesView extends StatefulWidget {
  final LatLng position;

  const NotesView({Key? key, required this.position}) : super(key: key);

  @override
  State<NotesView> createState() => _QrViewState();
}

class _QrViewState extends State<NotesView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notas'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: FormNote(position: widget.position),
          ),
        ));
  }
}
