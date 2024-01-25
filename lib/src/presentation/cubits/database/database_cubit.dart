import 'dart:async';
import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//domain
import '../../../domain/models/requests/database_request.dart';
import '../../../domain/models/table.dart';
import '../../../domain/repositories/api_repository.dart';
import '../../../domain/repositories/database_repository.dart';

//base
import '../base/base_cubit.dart';

//services
import '../../../locator.dart';
import '../../../services/storage.dart';

part 'database_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class DatabaseCubit extends BaseCubit<DatabaseState, String?> {
  final ApiRepository _apiRepository;
  final DatabaseRepository _databaseRepository;

  DatabaseCubit(this._apiRepository, this._databaseRepository)
      : super(const DatabaseLoading(), null);

  Timer? _timer;

  onTick(Timer timer, List<Table>? tables, int? currentIndex) {
    if (state is DatabaseInProgress) {
      DatabaseInProgress wip = state as DatabaseInProgress;
      if (wip.elapsed! <= 100) {
        emit(DatabaseInProgress(wip.elapsed! + 1,
            tables: tables, currentIndex: currentIndex));
      } else {
        _timer!.cancel();
        emit(const DatabaseInitial());
      }
    }
  }

  startWorkout([int? index, List<Table>? tables, int? currentIndex]) {
    if (index != null) {
      emit(DatabaseInProgress(0, tables: tables, currentIndex: currentIndex));
    } else {
      emit(DatabaseInProgress(0, tables: tables, currentIndex: currentIndex));
    }
    _timer = Timer.periodic(const Duration(seconds: 1),
        (timer) => onTick(timer, tables, currentIndex));
  }

  Future<void> getDatabase() async {
    emit(await _getDatabase());
  }

  Future<void> sendDatabase(String dbPath, String tableName) async {
    final response = await _apiRepository.database(
      request: DatabaseRequest(path: dbPath, tableName: tableName),
    );

    if (response is DatabaseSuccess) {
      emit(const DatabaseSuccess());
    } else {
      emit(DatabaseFailed(error: response.error));
    }
  }

  Future<DatabaseState> _getDatabase() async {
    var company = _storageService.getString('company');
    if (company != null) {
      var dir = await getApplicationDocumentsDirectory();
      var dbPath = '${dir.path}/$company.db';
      return DatabaseSuccess(dbPath: dbPath);
    } else {
      return const DatabaseSuccess(dbPath: null);
    }
  }

  String escapeSqlValue(dynamic value) {
    if (value is String) {
      return "'${value.replaceAll("'", "''")}'";
    } else if (value is DateTime) {
      return "'${value.toIso8601String()}'";
    } else {
      return value.toString();
    }
  }

  Future<bool> exportTable(
      Database database, String tableName, String outputPath) async {
    final result = await database.rawQuery('SELECT * FROM $tableName');

    if (result.isNotEmpty) {
      final columnNames = result.first.keys.toList();
      final sql = StringBuffer();
      sql.writeln('INSERT INTO $tableName (${columnNames.join(', ')}) VALUES');

      for (final row in result) {
        final values =
            columnNames.map((name) => escapeSqlValue(row[name])).join(', ');
        sql.writeln('($values),');
      }

      sql.writeln(';');
      final file = File(outputPath);

      await file.writeAsString(sql.toString().substring(0, sql.length - 2));

      sendDatabase(outputPath, tableName);

      return true;
    } else {
      return true;
    }
  }

  Future<bool> exportTableInBatches(
      Database database, String tableName, String outputPath) async {
    const batchSize = 1000;

    final totalRecords = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM $tableName'));
    final totalBatches = (totalRecords! / batchSize).ceil();

    for (var i = 0; i < totalBatches; i++) {
      final offset = i * batchSize;

      final result = await database
          .rawQuery('SELECT * FROM $tableName LIMIT $batchSize OFFSET $offset');

      if (result.isNotEmpty) {
        final columnNames = result.first.keys.toList();
        final sql = StringBuffer();
        sql.writeln(
            'INSERT INTO $tableName (${columnNames.join(', ')}) VALUES');
        for (final row in result) {
          final values =
              columnNames.map((name) => escapeSqlValue(row[name])).join(', ');
          sql.writeln('($values),');
        }

        sql.writeln(';');

        final file = File('$outputPath.$i.sql');
        await file.writeAsString(sql.toString().substring(0, sql.length - 2));

        sendDatabase(file.path, tableName);
      }
    }
    return true;
  }

  Future<void> exportDatabase(BuildContext context, bool main) async {
    if (isBusy) return;

    await run(() async {
      Database? database = await _databaseRepository.get();
      SnackBar? snackbar;

      final script = await database!
          .rawQuery('SELECT name FROM sqlite_master WHERE type="table"');

      final tables = script
          .map((e) => Table(
                name: e['name'] as String,
              ))
          .toList();

      final files = <String>[];

      for (final table in tables) {
        final fileName = '${table.name?.toLowerCase()}.sql';
        final filePath = join(await getDatabasesPath(), fileName);
        bool? r;
        var index = tables.indexOf(table);

        startWorkout(0, tables, index);

        if (table.name == 'summaries' ||
            table.name == 'transactions' ||
            table.name == 'locations') {
          r = await exportTableInBatches(database, table.name!, filePath);
          files.add(fileName);
          table.done = r;
        } else {
          r = await exportTable(database, table.name!, filePath);
          files.add(fileName);
          table.done = r;
        }

        if (r == false) break;
      }

      if (tables
              .where((element) => element.done == false || element.done == null)
              .isNotEmpty &&
          context.mounted) {
        main
            ? snackbar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error',
                  message: state.error!,
                  contentType: ContentType.failure,
                ),
              )
            : null;
      } else {
        main
            ? snackbar = SnackBar(
                duration: const Duration(seconds: 1),
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Perfecto!',
                  message: 'La base de datos se subió con éxito 🥳🥳🥳',
                  contentType: ContentType.success,
                ),
              )
            : null;
      }

      if (context.mounted && main) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackbar!);
      }

      final combinedFile =
          File(join(await getDatabasesPath(), 'all_tables.sql'));
      await combinedFile.writeAsString(files.map((f) => 'source $f;\n').join());
    });
  }
}
