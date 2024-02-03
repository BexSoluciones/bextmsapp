import 'package:flutter_test/flutter_test.dart';
//cubit
import 'package:bexdeliveries/src/presentation/cubits/home/home_cubit.dart';

void main() {
  group('HomeStatus', () {
    test('returns correct values for HomeStatus.initial', () {
      const status = HomeStatus.initial;

      expect(status.isInitial, isTrue);
      expect(status.isLoading, isFalse);
      expect(status.isSuccess, isFalse);
      expect(status.isError, isFalse);
    });

    test('returns correct values for HomeStatus.loading', () {
      const status = HomeStatus.loading;

      expect(status.isInitial, isFalse);
      expect(status.isLoading, isTrue);
      expect(status.isSuccess, isFalse);
      expect(status.isError, isFalse);
    });

    test('returns correct values for HomeStatus.isSuccess', () {
      const status = HomeStatus.success;
      expect(status.isInitial, isFalse);
      expect(status.isLoading, isFalse);
      expect(status.isSuccess, isTrue);
      expect(status.isError, isFalse);
    });

    test('returns correct values for HomeStatus.isFailure', () {
      const status = HomeStatus.failure;
      expect(status.isInitial, isFalse);
      expect(status.isLoading, isFalse);
      expect(status.isSuccess, isFalse);
      expect(status.isError, isTrue);
    });

  });
}