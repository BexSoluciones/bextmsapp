import 'package:flutter/material.dart';


import '../../utils/constants/colors.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key? key,
    required this.widget,
    required this.press,
    this.color

  }) : super(key: key);
  final Widget widget;
  final Color? color;
  final void Function() press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: color ?? Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: press,
          child: widget),
    );
  }
}
