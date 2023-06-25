import 'package:flutter/material.dart';

//utils
import '../../utils/extensions/app_theme.dart';

class DefaultButton extends StatelessWidget  {
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
            backgroundColor: color ?? context.theme.colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: press,
          child: widget),
    );
  }
}
