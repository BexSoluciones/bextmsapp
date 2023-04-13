import 'package:flutter/material.dart';

class UndefinedView extends StatelessWidget {
  @override
  const UndefinedView({Key? key, this.name}) : super(key: key);

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Route for $name is not defined'),
            ])));
  }
}
