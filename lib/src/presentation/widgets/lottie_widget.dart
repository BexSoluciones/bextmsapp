import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieWidget extends StatelessWidget {
  final String path;
  final String message;

  const LottieWidget({Key? key, required this.path, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Lottie.asset(path, height: 180, width: 180), Text(message)],
      ),
    );
  }
}
