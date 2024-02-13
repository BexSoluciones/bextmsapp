import 'package:flutter/material.dart';

Widget textField({
  required BuildContext context,
  required String hintTxt,
  required Function(String) onChanged,
  String? errorText,
  TextInputType? keyBoardType,
}) {
  return Container(
    height: 70.0,
    padding: const EdgeInsets.symmetric(horizontal: 30.0),
    margin: const EdgeInsets.symmetric(
      horizontal: 10.0,
      vertical: 10.0,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 270.0,
          child: TextField(
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: keyBoardType,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintTxt,
                errorText: errorText
            ),
          ),
        ),
      ],
    ),
  );
}