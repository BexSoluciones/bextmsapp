part of 'theme_bloc.dart';

class ThemeState {
  final bool isDarkTheme;

  ThemeState({required this.isDarkTheme});

  ThemeState copyWith({bool? isDarkTheme}) {
    return ThemeState(isDarkTheme: isDarkTheme ?? this.isDarkTheme);
  }
}