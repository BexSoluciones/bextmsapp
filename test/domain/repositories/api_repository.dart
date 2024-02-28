import 'package:flutter_test/flutter_test.dart';

//domain
import 'package:bexdeliveries/src/domain/models/requests/login_request.dart';
import 'package:bexdeliveries/src/domain/models/responses/login_response.dart';
import 'package:bexdeliveries/src/domain/repositories/api_repository.dart';

//utils
import 'package:bexdeliveries/src/utils/resources/data_state.dart';
import 'package:mockito/annotations.dart';
import 'api_repository.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<LoginRequest>(onMissingStub: null),
  MockSpec<LoginResponse>(onMissingStub: null),
])
class MockApiRepository extends Fake implements ApiRepository {
  DataState<LoginResponse> fakeGoodLoginResponse =
      DataSuccess(MockLoginResponse());

  DataState<LoginResponse> fakeBadLoginResponse =
      const DataFailed('Unexpected error occurred');

  @override
  Future<DataState<LoginResponse>> login(
      {required LoginRequest request}) async {
    if (request.username == "username" && request.password == "password") {
      return fakeGoodLoginResponse;
    }

    return fakeBadLoginResponse;
  }
}
