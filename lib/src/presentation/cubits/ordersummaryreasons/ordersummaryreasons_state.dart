part of 'ordersummaryreasons_cubit.dart';

@immutable
abstract class OrdersummaryreasonsState extends Equatable {

  final List<SummaryReport>? summariesRespawn;
  final List<SummaryReport>? summariesRejects;
  final List<SummaryReport>? summariesDelivery;
  final String? error;


   const OrdersummaryreasonsState({
     this.summariesRespawn,
     this.summariesRejects,
     this.summariesDelivery,
     this.error
  });

  @override
  List<Object?> get props => [
    summariesRespawn,
    summariesRejects,
    summariesDelivery,
    error
  ];

}

class OrdersummaryreasonsLoading extends OrdersummaryreasonsState {
   const OrdersummaryreasonsLoading();
}

class OrdersummaryreasonsSuccess extends OrdersummaryreasonsState {
  const OrdersummaryreasonsSuccess({List<SummaryReport>? summariesRespawn, List<SummaryReport>? summariesRejects, List<SummaryReport>? summariesDelivery}):super(summariesRespawn: summariesRespawn,summariesRejects: summariesRejects, summariesDelivery: summariesDelivery);
}

class OrdersummaryreasonsFailed extends OrdersummaryreasonsState{
   const OrdersummaryreasonsFailed({String? error}) : super(error: error);
}




