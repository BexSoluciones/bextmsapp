import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

//domain
import '../../../domain/models/work.dart';
import '../../../domain/repositories/database_repository.dart';

//utils
import '../base/base_cubit.dart';

//service
import '../../../services/navigation.dart';

part 'query_state.dart';

class QueryCubit extends BaseCubit<QueryState, List<Work>?> {
  final DatabaseRepository databaseRepository;
  final NavigationService navigationService;

  QueryCubit(this.databaseRepository, this.navigationService) : super(const QueryLoading(), []);

  Future<void> getWorks(String workcode) async {
    if (isBusy) return;

    await run(() async {
      try {
        final works = await databaseRepository.getAllWorks();
        final respawnList =
            await databaseRepository.getClientsResJetDel(workcode, 'respawn');
        final countTotalReturnRespawn = await databaseRepository
            .countTotalRespawnWorksByWorkcode(workcode, 'respawn');

        final rejectList =
            await databaseRepository.getClientsResJetDel(workcode, 'reject');
        final countTotalReturnReject = await databaseRepository
            .countTotalRespawnWorksByWorkcode(workcode, 'reject');

        final deliveryList =
            await databaseRepository.getClientsResJetDel(workcode, 'delivery');

        final partialList =
            await databaseRepository.getClientsResJetDel(workcode, 'partial');

        final countTotalReturnDelivery = await databaseRepository
            .countTotalCollectionWorksByWorkcode(workcode);

        var fixedCollectionList = [...deliveryList, ...partialList];

        final countTotalCollectionWork =
            await databaseRepository.countTotalCollectionWorks();
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
    await navigationService.goTo(url, arguments: args);
  }
}
