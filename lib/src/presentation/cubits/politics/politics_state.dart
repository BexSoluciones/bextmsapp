part of 'politics_cubit.dart';

abstract class PoliticsState extends Equatable {
  final String? token;
  final String? route;
  final String? error;

  const PoliticsState({this.token, this.route, this.error});

  @override
  List<Object?> get props => [token, route, error];
}

class PoliticsLoading extends PoliticsState {
  const PoliticsLoading();
}

class PoliticsSuccess extends PoliticsState {
  const PoliticsSuccess({super.token, super.route});
}

class PoliticsFailed extends PoliticsState {
  const PoliticsFailed({super.error});
}
