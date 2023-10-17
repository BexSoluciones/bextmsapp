import 'dart:math';

import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? defaultSize;
  static double? textScaleFactor;
  static Orientation? orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    orientation = _mediaQueryData!.orientation;
    textScaleFactor = _mediaQueryData!.textScaleFactor;
  }
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  final screenHeight = SizeConfig.screenHeight;

  if (screenHeight != null) {
    // 812 is the layout height that designer uses
    return (inputHeight / 812.0) * screenHeight;
  }
  return inputHeight;
}


// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  final screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use

  return (inputWidth / 375.0) * screenWidth!;
}

double? getFullScreenHeight() {
  return SizeConfig.screenHeight;
}

double? getFullScreenWidth() {
  return SizeConfig.screenWidth;
}

double? getTextScaleFactor() {
  return SizeConfig.textScaleFactor;
}

double textScaleFactor(BuildContext context, {double maxTextScaleFactor = 2}) {
  final width = SizeConfig.screenWidth;
  final height = SizeConfig.screenHeight;

  if (width != null && height != null) {
    var val = (width / height) * maxTextScaleFactor;
    return max(1, min(val, maxTextScaleFactor));
  }
  return 1.0;
}

