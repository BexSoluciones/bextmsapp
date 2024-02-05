import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../firebase_mock.dart';
//domain
import 'package:bexdeliveries/src/presentation/blocs/issues/issues_bloc.dart';
//services
import '../../../locator_mock.dart';
import '../../../locator_mock.mocks.dart';

void main() {
  setupFirebaseAuthMocks();

  late MockDatabaseRepository databaseRepository;

  setUpAll(() async {
    await Firebase.initializeApp();
    databaseRepository = MockDatabaseRepository();
  });


}