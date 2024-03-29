import 'package:flutter/material.dart';

class CustomMaterialButton extends StatelessWidget {
  final Function() onButtonPressed;
  final String buttonText;

  const CustomMaterialButton(
      {super.key, required this.onButtonPressed, required this.buttonText});
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      disabledColor: Colors.grey,
      onPressed: onButtonPressed,
      splashColor: Colors.green,
      color: Colors.green,
      minWidth: MediaQuery.of(context).size.width * 0.8,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
      ),
      animationDuration: const Duration(seconds: 1),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: Text(buttonText.toString().toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.height * 0.025,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
