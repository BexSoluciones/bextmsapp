part of 'query_cubit.dart';

abstract class QueryState extends Equatable {
  final List<Work>? works;
  final double? totalCollection;

  final List<WorkAdditional>? respawns;
  final double? totalRespawn;

  final List<WorkAdditional>? rejects;
  final double? totalReject;

  final String? error;

  const QueryState(
      {this.works,
      this.totalCollection,
      this.respawns,
      this.totalRespawn,
      this.rejects,
      this.totalReject,
      this.error});

  @override
  List<Object?> get props => [
        works,
        totalCollection,
        respawns,
        totalRespawn,
        rejects,
        totalReject,
        error
      ];
}

class QueryLoading extends QueryState {
  const QueryLoading();
}

class QuerySuccess extends QueryState {
  const QuerySuccess({super.works});
}

// class QuerySuccessCollection extends QueryState {
//   const QuerySuccessCollection({super.works});
// }
//
// class QuerySuccessRespawm extends QueryState {
//   const QuerySuccess({super.works});
// }
//
// class QuerySuccess extends QueryState {
//   const QuerySuccess({super.works});
// }

class QueryFailed extends QueryState {
  const QueryFailed({super.error});
}
