import 'dart:convert';

import 'package:bexdeliveries/src/presentation/cubits/login/login_cubit.dart';
import 'package:bexdeliveries/src/services/notifications.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

//cubits
import '../base/base_cubit.dart';

//domains
import '../../../domain/models/enterprise.dart';
import '../../../domain/models/requests/enterprise_request.dart';
import '../../../domain/repositories/api_repository.dart';

//utils
import '../../../utils/resources/data_state.dart';
import '../../../utils/constants/strings.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'initial_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();
final NotificationService _notificationService = locator<NotificationService>();

class InitialCubit extends BaseCubit<InitialState, Enterprise?> {
  final ApiRepository _apiRepository;

  InitialCubit(this._apiRepository)
      : super(
            InitialSuccess(
                enterprise: _storageService.getObject('enterprise') != null
                    ? Enterprise.fromMap(
                        _storageService.getObject('enterprise')!)
                    : null,
                token: _notificationService.token),
            null);

  Future<void> getEnterprise(
      TextEditingController companyNameController, LoginCubit loginCubit) async {
    if (isBusy) return;

    await run(() async {
      emit(const InitialLoading());

      _storageService.setString('company', companyNameController.text);

      final response = await _apiRepository.getEnterprise(
        request: EnterpriseRequest(companyNameController.text),
      );

      if (response is DataSuccess) {
        final enterprise = response.data!.enterprise;
        _storageService.setObject('enterprise', enterprise.toMap());
        loginCubit.updateEnterpriseState(enterprise);

        var token = _notificationService.token;
        print('token from initial');
        print(token);
        emit(InitialSuccess(enterprise: enterprise, token: token));
      } else if (response is DataFailed) {
        _storageService.setString('company', null);
        emit(InitialFailed(error: response.error));
      }
    });
  }

  void goToLogin() {
    _navigationService.replaceTo(AppRoutes.login);
  }
}
