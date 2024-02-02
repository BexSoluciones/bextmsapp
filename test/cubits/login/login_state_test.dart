import 'package:flutter_test/flutter_test.dart';
//cubit
import 'package:bexdeliveries/src/presentation/cubits/login/login_cubit.dart';

void main() {
  group('LoginStatus', () {

    test('returns correct values for LoginStatus.loading', () {
      const status = LoginLoading;

      expect(status == LoginLoading, isTrue);
      expect(status == LoginSuccess, isFalse);
      expect(status == LoginFailed, isFalse);
    });

    test('returns correct values for LoginStatus.isSuccess', () {
      const status = LoginSuccess;

      expect(status == LoginLoading, isFalse);
      expect(status == LoginSuccess, isTrue);
      expect(status == LoginFailed, isFalse);
    });

    test('returns correct values for LoginStatus.isFailure', () {
      const status = LoginFailed;

      expect(status == LoginLoading, isFalse);
      expect(status == LoginSuccess, isFalse);
      expect(status == LoginFailed, isTrue);
    });

  });
}