import '../../utils/resources/data_state.dart';

import '../models/requests/enterprise_request.dart';
import '../models/responses/enterprise_response.dart';

import '../models/requests/login_request.dart';
import '../models/responses/login_response.dart';

import '../models/requests/logout_request.dart';
import '../models/responses/logout_response.dart';

import '../models/requests/work_request.dart';
import '../models/responses/work_response.dart';

import '../models/requests/database_request.dart';
import '../models/responses/database_response.dart';

import '../models/requests/enterprise_config_request.dart';
import '../models/responses/enterprise_config_response.dart';

import '../models/requests/reason_request.dart';
import '../models/responses/reason_response.dart';

import '../models/requests/transaction_request.dart';
import '../models/responses/transaction_response.dart';

import '../models/requests/transaction_summary_request.dart';
import '../models/responses/transaction_summary_response.dart';

import '../models/requests/status_request.dart';
import '../models/responses/status_response.dart';

abstract class ApiRepository {
  //SYNCHRONOUS
  Future<DataState<EnterpriseResponse>> getEnterprise({
    required EnterpriseRequest request,
  });

  Future<DataState<EnterpriseConfigResponse>> getConfigEnterprise({
    required EnterpriseConfigRequest request,
  });

  Future<DataState<ReasonResponse>> reasons({
    required ReasonRequest request,
  });

  Future<DataState<LoginResponse>> login({
    required LoginRequest request,
  });

  Future<DataState<LogoutResponse>> logout({
    required LogoutRequest request,
  });

  Future<DataState<WorkResponse>> works({
    required WorkRequest request
  });

  Future<DataState<DatabaseResponse>> database({
    required DatabaseRequest request
  });

  //ASYNCHRONOUS
  Future<DataState<StatusResponse>> status({
    required StatusRequest request
  });

  Future<DataState<TransactionResponse>> start({
    required TransactionRequest request
  });

  Future<DataState<TransactionResponse>> arrived({
    required TransactionRequest request
  });

  Future<DataState<TransactionResponse>> summary({
    required TransactionRequest request
  });

  Future<DataState<TransactionResponse>> index({
    required TransactionRequest request
  });

  Future<DataState<TransactionResponse>> transaction({
    required TransactionSummaryRequest request
  });

  Future<DataState<TransactionSummaryResponse>> product({
    required TransactionSummaryRequest request
  });
}