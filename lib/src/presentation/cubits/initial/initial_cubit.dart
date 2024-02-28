import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

//cubits
import '../base/base_cubit.dart';
import '../login/login_cubit.dart';

//domains
import '../../../domain/models/enterprise.dart';
import '../../../domain/models/requests/enterprise_request.dart';
import '../../../domain/repositories/api_repository.dart';

//utils
import '../../../utils/resources/data_state.dart';
import '../../../utils/constants/strings.dart';

//service
import '../../../services/storage.dart';
import '../../../services/navigation.dart';
import '../../../services/notifications.dart';

part 'initial_state.dart';

class InitialCubit extends BaseCubit<InitialState, Enterprise?> {
  final ApiRepository apiRepository;
  final LocalStorageService storageService;
  final NavigationService navigationService;
  final NotificationService notificationService;


  InitialCubit(this.apiRepository, this.storageService, this.navigationService, this.notificationService)
      : super(
            InitialSuccess(
                enterprise: storageService.getObject('enterprise') != null
                    ? Enterprise.fromMap(
                        storageService.getObject('enterprise')!)
                    : null,
                token: notificationService.token),
            null);

  Future<void> getEnterprise(
      TextEditingController companyNameController, LoginCubit loginCubit) async {
    if (isBusy) return;

    await run(() async {
      emit(const InitialLoading());

      storageService.setString('company', companyNameController.text);

      final response = await apiRepository.getEnterprise(
        request: EnterpriseRequest(companyNameController.text),
      );

      if (response is DataSuccess) {
        final enterprise = response.data!.enterprise;
        storageService.setObject('enterprise', enterprise.toMap());
        loginCubit.updateEnterpriseState(enterprise);

        var token = notificationService.token;
        emit(InitialSuccess(enterprise: enterprise, token: token));
      } else if (response is DataFailed) {
        storageService.setString('company', null);
        emit(InitialFailed(error: response.error));
      }
    });
  }

  void goToLogin() {
    navigationService.replaceTo(AppRoutes.login);
  }
}
