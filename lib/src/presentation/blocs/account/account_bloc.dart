import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
//domain
import '../../../domain/models/account.dart';
import '../../../domain/repositories/database_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final DatabaseRepository databaseRepository;

  AccountBloc(this.databaseRepository) : super(AccountLoadingState()) {
    on<LoadAccountListEvent>((event, emit) async {
      emit(AccountLoadingState());
      try {
        final accounts = await databaseRepository.getAllAccounts();
        accounts.insert(0, Account(id: 0, name: 'Selecciona una cuenta'));
        emit(AccountLoadedState(accounts));
      } catch (e, stackTrace) {
        emit(AccountErrorState('Error loading accounts: $e'));
        await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
    });
  }
}
