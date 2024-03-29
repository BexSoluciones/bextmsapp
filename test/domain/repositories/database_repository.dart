import 'package:flutter_test/flutter_test.dart';
//domain
import 'package:bexdeliveries/src/domain/models/account.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';

class MockDatabaseRepository extends Fake implements DatabaseRepository {
  @override
  Future<List<Account>> getAllAccounts() async {
    return [];
  }
}