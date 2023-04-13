part of 'database_cubit.dart';

abstract class DatabaseState extends Equatable {

  final String? dbPath;
  final String? error;

  const DatabaseState({
    this.dbPath,
    this.error
});

  @override
  List<Object?> get props => [dbPath, error];
}

class DatabaseLoading extends DatabaseState {
  const DatabaseLoading();
}

class DatabaseSuccess extends DatabaseState {
  const DatabaseSuccess({super.dbPath});
}

class DatabaseFailed extends DatabaseState {
  const DatabaseFailed({super.error});
}
