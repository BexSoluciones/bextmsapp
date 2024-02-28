import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

Widget textField({
  required BuildContext context,
  Function(String)? onChanged,
  Function()? onClear,
  Function()? onTap,
  Key? key,
  String? initialValue,
  String? prefixText,
  String? errorText,
  TextInputType? keyBoardType,
  bool? readOnly
}) {
  return TextFormField(
    key: key,
    initialValue: initialValue,
    readOnly: readOnly ?? false,
    autofocus: false,
    decoration: InputDecoration(
      prefixText: prefixText,
      errorText: errorText,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 2.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
      ),
      suffixIcon: IconButton(
        onPressed: onClear,
        icon: const Icon(Icons.clear),
      ),
    ),
    onTap: onTap,
    onChanged: onChanged,
    textAlignVertical: TextAlignVertical.center,
    keyboardType: keyBoardType,
  );
}
