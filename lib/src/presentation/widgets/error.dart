import 'package:flutter/material.dart';

class Error extends StatelessWidget {
  final String message;

  const Error({super.key, this.message = "Camera Error"});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Icon(Icons.error), Center(child: Text(message))]),
    );
  }
}
