part of 'work_bloc.dart';

abstract class WorkState extends Equatable {
  final List<Work>? works;
  final List<Work>? visited;
  final List<Work>? notVisited;
  final List<Work>? notGeoreferenced;

  final bool? started;
  final bool? blocked;
  final bool? confirm;
  final bool? noMoreData;

  final int? limit;
  final int? index;
  final int? key;

  final String? workcode;

  const WorkState(
      {this.limit = 10,
      this.works = const [],
      this.visited = const [],
      this.notVisited = const [],
      this.notGeoreferenced = const [],
      this.noMoreData = true,
      this.started = false,
      this.blocked = false,
      this.confirm = false,
      this.index = 0,
      this.key = 0,
      this.workcode});

  @override
  List<Object?> get props => [
        limit,
        works,
        visited,
        notVisited,
        notGeoreferenced,
        noMoreData,
        started,
        blocked,
        confirm,
        index,
        key,
        workcode
      ];
}

class Initial extends WorkState {}

class Loading extends WorkState {}

class Loaded extends WorkState {
  const Loaded(
      {super.limit,
      super.workcode,
      super.works,
      super.visited,
      super.notVisited,
      super.notGeoreferenced,
      super.noMoreData,
      super.started,
      super.blocked,
      super.confirm,
      super.index,
      super.key});
}
