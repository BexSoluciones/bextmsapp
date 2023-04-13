import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

//domains
import '../../../domain/models/enterprise.dart';
import '../../../domain/models/requests/enterprise_request.dart';
import '../../../domain/repositories/api_repository.dart';

//utils
import '../../../utils/resources/data_state.dart';
import '../base/base_cubit.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';

part 'initial_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class InitialCubit extends BaseCubit<InitialState, Enterprise?> {
  final ApiRepository _apiRepository;

  InitialCubit(this._apiRepository)
      : super(
            InitialSuccess(
                enterprise: _storageService.getObject('enterprise') != null
                    ? Enterprise.fromMap(
                        _storageService.getObject('enterprise')!)
                    : null),
            null);

  Future<void> getEnterprise(
      TextEditingController companyNameController) async {
    if (isBusy) return;

    await run(() async {
      _storageService.setString('company_name', companyNameController.text);

      final response = await _apiRepository.getEnterprise(
        request: EnterpriseRequest(companyNameController.text),
      );

      if (response is DataSuccess) {
        final enterprise = response.data!.enterprise;
        _storageService.setObject('enterprise', enterprise.toMap());
        emit(InitialSuccess(enterprise: enterprise));
      } else if (response is DataFailed) {
        _storageService.setString('company_name', null);
        emit(InitialFailed(error: response.error));
      }
    });
  }
}
