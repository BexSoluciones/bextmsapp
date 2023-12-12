import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
//domain
import '../../../domain/models/account.dart';
import '../../../domain/repositories/database_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final DatabaseRepository _databaseRepository;

  AccountBloc(this._databaseRepository) : super(AccountLoadingState()) {
    on<LoadAccountListEvent>((event, emit) async {
      emit(AccountLoadingState());
      try {
        final accounts = await _databaseRepository.getAllAccounts();
        emit(AccountLoadedState(accounts));
      } catch (e, stackTrace) {
        emit(AccountErrorState('Error loading accounts: $e'));
        await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
    });
  }
}
