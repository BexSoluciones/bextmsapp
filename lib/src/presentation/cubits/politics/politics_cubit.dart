import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

//utils
import '../../../utils/constants/strings.dart';
import '../base/base_cubit.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';

part 'politics_state.dart';

class PoliticsCubit extends BaseCubit<PoliticsState, String?> {
  final LocalStorageService storageService;

  PoliticsCubit(this.storageService)
      : super(PoliticsSuccess(token: storageService.getString('token')), null);

  Future<void> goTo() async {
    if (isBusy) return;

    await run(() async {
      try {
        storageService.setBool('first_time', true);
        var token = storageService.getString('token');
        String route;

        if (token != null) {
          route = AppRoutes.home;
        } else {
          route = AppRoutes.permission;
        }

        emit(PoliticsSuccess(
            token: storageService.getString('token'), route: route));
      } catch (e, stackTrace) {
        emit(PoliticsFailed(error: e.toString()));
        await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
    });
  }
}
