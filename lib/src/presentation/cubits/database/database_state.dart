part of 'database_cubit.dart';

abstract class DatabaseState extends Equatable {
  final String? dbPath;
  final List<Table>? tables;

  final String? tableName;
  final int? totalTables;
  final int? elapsed;
  final int? currentIndex;

  final String? error;

  const DatabaseState(
      {this.dbPath,
      this.tables,
      this.tableName,
      this.totalTables,
      this.error,
      this.currentIndex,
      this.elapsed});

  @override
  List<Object?> get props =>
      [dbPath, tables, tableName, totalTables, error, elapsed];
}

class DatabaseInitial extends DatabaseState {
  const DatabaseInitial();
}

class DatabaseLoading extends DatabaseState {
  const DatabaseLoading({super.dbPath, super.tables, super.totalTables});
}

class DatabaseInProgress extends DatabaseState {
  const DatabaseInProgress(elapsed, {super.tables, super.currentIndex})
      : super(elapsed: elapsed);

  @override
  List<Object?> get props => [elapsed, currentIndex];
}

class DatabaseSuccess extends DatabaseState {
  const DatabaseSuccess({super.dbPath});
}

class DatabaseFailed extends DatabaseState {
  const DatabaseFailed({super.error});
}
