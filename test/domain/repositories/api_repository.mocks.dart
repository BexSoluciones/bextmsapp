// Mocks generated by Mockito 5.4.4 from annotations
// in bexdeliveries/test/domain/repositories/api_repository.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bexdeliveries/src/domain/models/login.dart' as _i2;
import 'package:bexdeliveries/src/domain/models/requests/login_request.dart'
    as _i3;
import 'package:bexdeliveries/src/domain/models/responses/login_response.dart'
    as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i4;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeLogin_0 extends _i1.SmartFake implements _i2.Login {
  _FakeLogin_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [LoginRequest].
///
/// See the documentation for Mockito's code generation for more information.
class MockLoginRequest extends _i1.Mock implements _i3.LoginRequest {
  MockLoginRequest() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get username => (super.noSuchMethod(
        Invocation.getter(#username),
        returnValue: _i4.dummyValue<String>(
          this,
          Invocation.getter(#username),
        ),
      ) as String);

  @override
  String get password => (super.noSuchMethod(
        Invocation.getter(#password),
        returnValue: _i4.dummyValue<String>(
          this,
          Invocation.getter(#password),
        ),
      ) as String);
}

/// A class which mocks [LoginResponse].
///
/// See the documentation for Mockito's code generation for more information.
class MockLoginResponse extends _i1.Mock implements _i5.LoginResponse {
  MockLoginResponse() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Login get login => (super.noSuchMethod(
        Invocation.getter(#login),
        returnValue: _FakeLogin_0(
          this,
          Invocation.getter(#login),
        ),
      ) as _i2.Login);

  @override
  bool get stringify => (super.noSuchMethod(
        Invocation.getter(#stringify),
        returnValue: false,
      ) as bool);

  @override
  List<Object> get props => (super.noSuchMethod(
        Invocation.getter(#props),
        returnValue: <Object>[],
      ) as List<Object>);
}
