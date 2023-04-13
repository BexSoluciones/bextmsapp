import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(isDarkTheme: true)) {
    on<ChangeTheme>(
      (event, emit) {
        if (state.isDarkTheme) {
          emit(state.copyWith(isDarkTheme: false));
        } else {
          emit(state.copyWith(isDarkTheme: true));
        }
      },
    );
  }
}
