import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../domain/repositories/database_repository.dart';
import '../../../firebase_mock.dart';

import 'package:bexdeliveries/src/presentation/blocs/account/account_bloc.dart';

void main() {
  setupFirebaseAuthMocks();

  late MockDatabaseRepository databaseRepository;

  setUpAll(() async {
    await Firebase.initializeApp();
    databaseRepository = MockDatabaseRepository();
  });

  group('AccountInitialized', () {
    blocTest<AccountBloc, AccountState>(
      'Should initialize list of a accounts empty',
      build: () => AccountBloc(databaseRepository),
      act: (AccountBloc bloc) => bloc.add(LoadAccountListEvent()),
      expect: <AccountState>() => [
        isA<AccountLoadingState>(),
        isA<AccountLoadedState>(),
      ],
    );
  });
}
