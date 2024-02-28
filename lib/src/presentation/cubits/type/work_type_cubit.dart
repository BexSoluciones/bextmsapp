import 'package:bexdeliveries/src/domain/models/work.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:bexdeliveries/src/presentation/cubits/base/base_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';

part 'work_type_state.dart';

class WorkTypeCubit extends BaseCubit<WorkTypeState, List<WorkTypes>?> {
  final DatabaseRepository databaseRepository;

  WorkTypeCubit(this.databaseRepository) : super(const WorkTypeCubitLoading(),[]);

  Future<void> getWorkTypesFromWork(String workCode) async {
    if (isBusy) return;


    await run(() async {
      try {
        final workTypes = await databaseRepository.getWorkTypesFromWorkcode(workCode);
        emit(WorkTypeCubitSuccess(workTypes:workTypes));
      } catch (error, stackTrace) {
        await FirebaseCrashlytics.instance.recordError(error, stackTrace);
        emit(WorkTypeCubitFailed(error: error.toString()));
      }
    });

  }
}

