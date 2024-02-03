import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../utils/constants/strings.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final LocalStorageService storageService;

  SplashBloc({required this.storageService}) : super(Initial()) {
    on<HandleNavigateEvent>(_observe);
  }

  void _observe(event, emit) async {
    await Future.delayed(const Duration(seconds: 2));
    await isFirstTime().then((firstTime) async {
      if (firstTime == null || firstTime == false) {
        emit(const Loaded(route: AppRoutes.politics));
      } else {
        var token = storageService.getString('token');
        var company = storageService.getString('company');

        if (token != null) {
          emit(const Loaded(route: AppRoutes.home));
        } else if (company != null) {
          emit(const Loaded(route: AppRoutes.login));
        } else {
          emit(const Loaded(route: AppRoutes.company));
        }
      }
    });
  }

  Stream<SplashState> mapEventToState(
    SplashState event,
  ) async* {
    if (event is HandleNavigateEvent) {
      yield Loading();
      await Future.delayed(const Duration(seconds: 3));
      isFirstTime().then((firstTime) async* {
        if (!firstTime!) {
          yield const Loaded(route: '/politics');
        } else {
          validateSession();
        }
      });
    }
  }

  Future<bool?> isFirstTime() async {
    return storageService.getBool('first_time');
  }

  Stream<Loaded> validateSession() async* {
    var token = storageService.getString('token');
    var company = storageService.getString('company');
    if (token != null) {
      yield const Loaded(route: AppRoutes.home);
    } else if (company != null) {
      yield const Loaded(route: AppRoutes.login);
    } else {
      yield const Loaded(route: AppRoutes.company);
    }
  }
}
