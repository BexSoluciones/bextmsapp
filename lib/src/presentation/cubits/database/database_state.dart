part of 'database_cubit.dart';

abstract class DatabaseState extends Equatable {
  final String? dbPath;
  final List<String>? tables;

  final String? tableName;
  final int? totalTables;

  final String? error;

  const DatabaseState(
      {this.dbPath, this.tables, this.tableName, this.totalTables, this.error});

  @override
  List<Object?> get props => [dbPath, tables, tableName, totalTables, error];
}

class DatabaseInitial extends DatabaseState {
  const DatabaseInitial();
}

class DatabaseLoading extends DatabaseState {
  const DatabaseLoading({super.dbPath, super.tables, super.totalTables});
}

class DatabaseSuccess extends DatabaseState {
  const DatabaseSuccess({super.dbPath});
}

class DatabaseFailed extends DatabaseState {
  const DatabaseFailed({super.error});
}
