import 'package:flutter/material.dart';

class AppTextTheme extends ThemeExtension<AppTextTheme> {
  const AppTextTheme({
    required this.body1,
    required this.h1,
  });

  final TextStyle body1;
  final TextStyle h1;

  @override
  ThemeExtension<AppTextTheme> copyWith({
    TextStyle? body1,
    TextStyle? h1,
  }) {
    return AppTextTheme(
      body1: body1 ?? this.body1,
      h1: h1 ?? this.h1,
    );
  }

  @override
  ThemeExtension<AppTextTheme> lerp(
      covariant ThemeExtension<AppTextTheme>? other,
      double t,
      ) {
    if (other is! AppTextTheme) {
      return this;
    }

    return AppTextTheme(
      body1: TextStyle.lerp(body1, other.body1, t)!,
      h1: TextStyle.lerp(h1, other.h1, t)!,
    );
  }
}

abstract class AppTypography {
  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const h1 = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w300,
  );
}