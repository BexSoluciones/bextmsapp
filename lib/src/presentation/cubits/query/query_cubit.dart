
import 'package:equatable/equatable.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/repositories/database_repository.dart';

//utils

import '../../../utils/constants/strings.dart';
import '../base/base_cubit.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';
import '../../../services/navigation.dart';

part 'query_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();

class QueryCubit extends BaseCubit<QueryState, List<Work>?> {

  final DatabaseRepository _databaseRepository;

  QueryCubit(this._databaseRepository) : super(const QueryLoading(), []);

  Future<void> getWorks() async {
    if (isBusy) return;

    await run(() async {
      try{
        final works = await _databaseRepository.getAllWorks();

        data = [];

        await Future.forEach(works, (work) async {
          var dob = DateTime.parse(work.date!);
          var dur = DateTime.now().difference(dob);

          // if (dur.inDays > _storageService.getInt('limit_days_works')! &&
          //     work.status == 'complete') {
          //   // await database.deleteTransactionsByWorkcode(work.workcode);
          //   // await database.deleteWork(work);
          // } else {
          //
          // }

          data?.add(work);
        }).then((value) => emit(QuerySuccess(works: data)));


      } catch (e) {
        emit(QueryFailed(error: e.toString()));
      }
    });
  }

  Future<void> goTo(url, args) async {
    await _navigationService.goTo(url, arguments: args);
  }
}