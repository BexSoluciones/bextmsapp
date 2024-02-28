import 'dart:async';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/database_repository.dart';
import '../base/base_cubit.dart';

part 'count_state.dart';

class CountCubit extends BaseCubit<CountState, bool> {
  final DatabaseRepository databaseRepository;
  CountCubit(this.databaseRepository) : super(const CountLoading(), false);

  Future<void> getCountNotification() async {
    if (isBusy) return;
    await run(() async {
      try {
        final countNotification =
            await databaseRepository.countAllUnreadNotifications();
        emit(CountSuccess(count: countNotification));
      } catch (error) {
        emit(CountFailed(error: error.toString()));
      }
    });
  }
}
