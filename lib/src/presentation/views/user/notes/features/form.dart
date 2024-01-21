import 'package:bexdeliveries/src/presentation/widgets/default_button_widget.dart';
import 'package:bexdeliveries/src/utils/constants/colors.dart';
import 'package:bexdeliveries/src/utils/constants/gaps.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

//utils

//widgets


class FormNote extends StatefulWidget {

  final LatLng position;

  const FormNote({super.key, required this.position});

  @override
  State<StatefulWidget> createState() => FormNoteState();
}

class FormNoteState extends State<FormNote> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(widget.position.longitude.toString()),
          Text(widget.position.latitude.toString()),
          DefaultButton(
            widget: const Icon(Icons.camera_alt, color: Colors.white),
            press: () {},
          ),

          gapH16,
          const Text('Observaciones'),
          gapH4,
          TextFormField(
            maxLines: 6,
            decoration: const InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              suffixText: 'Observaciones'
            ),
          ),
          gapH16,
          DefaultButton(
            widget: const Text('Guardar', style: TextStyle(color: Colors.white, fontSize: 18)),
            press: () {},
          )
        ],
      ),
    );
  }
}
