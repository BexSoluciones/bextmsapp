import 'package:flutter/material.dart';

class UndefinedView extends StatelessWidget {
  @override
  const UndefinedView({super.key, this.name});

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
