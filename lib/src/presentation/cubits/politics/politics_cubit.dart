
import 'package:equatable/equatable.dart';

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
          route = homeRoute;
        } else {
          route = permissionRoute;
        }

        emit(PoliticsSuccess(token: _storageService.getString('token'), route: route));
      } catch (e) {
        emit(PoliticsFailed(error: e.toString()));
      }
    });
  }
}