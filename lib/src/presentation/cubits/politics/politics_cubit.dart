
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

//utils
import '../../../utils/constants/strings.dart';
import '../base/base_cubit.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';

part 'politics_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class PoliticsCubit extends BaseCubit<PoliticsState, String?> {

  PoliticsCubit() : super(PoliticsSuccess(token: _storageService.getString('token')), null);

  Future<void> goTo() async {
    if (isBusy) return;

    await run(() async {
      try {
        _storageService.setBool('first_time', true);
        var token  = _storageService.getString('token');
        String route;

        if (token != null) {
          route = AppRoutes.home;
        } else {
          route = AppRoutes.permission;
        }

        emit(PoliticsSuccess(token: _storageService.getString('token'), route: route));
      } catch (e,stackTrace) {
        emit(PoliticsFailed(error: e.toString()));
        await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
    });
  }
}