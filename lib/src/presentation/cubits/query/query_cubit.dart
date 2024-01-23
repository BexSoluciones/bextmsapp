import 'package:bexdeliveries/src/services/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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

final NavigationService _navigationService = locator<NavigationService>();

class QueryCubit extends BaseCubit<QueryState, List<Work>?> {
  final DatabaseRepository _databaseRepository;

  QueryCubit(this._databaseRepository) : super(const QueryLoading(), []);

  Future<void> getWorks(String workcode) async {
    if (isBusy) return;

    await run(() async {
      try {
        final works = await _databaseRepository.getAllWorks();
        final respawnList =
            await _databaseRepository.getClientsResJetDel(workcode, 'respawn');
        final countTotalReturnRespawn = await _databaseRepository
            .countTotalRespawnWorksByWorkcode(workcode, 'respawn');

        final rejectList =
            await _databaseRepository.getClientsResJetDel(workcode, 'reject');
        final countTotalReturnReject = await _databaseRepository
            .countTotalRespawnWorksByWorkcode(workcode, 'reject');

        final deliveryList =
            await _databaseRepository.getClientsResJetDel(workcode, 'delivery');

        final partialList =
            await _databaseRepository.getClientsResJetDel(workcode, 'partial');

        final countTotalReturnDelivery = await _databaseRepository
            .countTotalCollectionWorksByWorkcode(workcode);

        print(countTotalReturnDelivery);

        var fixedCollectionList = [...deliveryList, ...partialList];

        final countTotalCollectionWork =
            await _databaseRepository.countTotalCollectionWorks();
        data = [];

        await Future.forEach(works, (work) async {
          data?.add(work);
        }).then((value) => emit(QuerySuccess(
            works: data,
            respawns: respawnList,
            totalRespawn: countTotalReturnRespawn,
            rejects: rejectList,
            totalRejects: countTotalReturnReject,
            delivery: fixedCollectionList,
            totalDelivery: countTotalReturnDelivery,
            countTotalCollectionWorks: countTotalCollectionWork)));
      } catch (e, stackTrace) {
        emit(QueryFailed(error: e.toString()));
        await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
    });
  }

  Future<void> goTo(url, args) async {
    await _navigationService.goTo(url, arguments: args);
  }
}
