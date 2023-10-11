part of 'query_cubit.dart';

abstract class QueryState extends Equatable {
  final List<Work>? works;
  final double? totalCollection;

  final List<WorkAdditional>? respawns;
  final double? totalRespawn;

  final List<WorkAdditional>? rejects;
  final double? totalReject;

  final List<WorkAdditional>? delivery;
  final double? totalDelivery;



  final String? error;

  const QueryState({
    this.works,
    this.totalCollection,
    this.respawns,
    this.totalRespawn,
    this.rejects,
    this.totalReject,
    this.delivery,
    this.totalDelivery,
    this.error,
  });

  @override
  List<Object?> get props => [
    works,
    totalCollection,
    respawns,
    totalRespawn,
    rejects,
    totalReject,
    delivery,
    totalDelivery,
    error,
  ];
}

class QueryLoading extends QueryState {
  const QueryLoading();
}

class QuerySuccess extends QueryState {
  const QuerySuccess({List<Work>? works,List<WorkAdditional>? respawns,double? totalRespawn, List<WorkAdditional>? rejects,double? totalRejects, List<WorkAdditional>? delivery,double? totalDelivery} ) : super(works: works,respawns: respawns,totalRespawn:totalRespawn,rejects: rejects,totalReject: totalRejects, delivery: delivery,totalDelivery: totalDelivery);
}

class QuerySuccessCollection extends QueryState {
  const QuerySuccessCollection({List<Work>? works, double? totalCollection,List<WorkAdditional>? respawns,double? totalRespawn,List<WorkAdditional>? rejects,double? totalRejects,List<WorkAdditional>? delivery,double? totalDelivery })
      : super(works: works, totalCollection: totalCollection,respawns: respawns,totalRespawn: totalRespawn,rejects: rejects,totalReject: totalRejects, delivery: delivery,totalDelivery: totalDelivery);
}


class QueryFailed extends QueryState {
  const QueryFailed({String? error}) : super(error: error);
}


