import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

Widget textField({
  required BuildContext context,
  Function(String)? onChanged,
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
        onPressed: () {
          // if (double.tryParse(widget
          //         .collectionCubit.transferController.text) !=
          //     null) {
          //   widget.collectionCubit.total = widget
          //           .collectionCubit.total -
          //       double.parse(
          //           widget.collectionCubit.cashController.text);
          // }
          // widget.collectionCubit.selectedAccounts.clear();
          // widget.collectionCubit.cashController.clear();
        },
        icon: const Icon(Icons.clear),
      ),
    ),
    onTap: onTap,
    onChanged: onChanged,
    textAlignVertical: TextAlignVertical.center,
    keyboardType: keyBoardType,
  );
}
