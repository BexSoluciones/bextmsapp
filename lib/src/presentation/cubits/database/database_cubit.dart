import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//domain
import '../../../domain/models/requests/database_request.dart';
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

  Future<void> getDatabase() async {
    emit(await _getDatabase());
  }

  Future<void> sendDatabase(String dbPath, String tableName) async {
    if (isBusy) return;

    await run(() async {
      emit(const DatabaseLoading());

      final response = await _apiRepository.database(
        request: DatabaseRequest(path: dbPath, tableName: tableName),
      );

      if (response is DatabaseSuccess) {
        emit(const DatabaseSuccess());
      } else {
        emit(DatabaseFailed(error: response.error));
      }
    });
  }

  Future<DatabaseState> _getDatabase() async {
    var company = _storageService.getString('company_name');
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

      // Actualiza el contador de archivos enviados en el proveedor de datos
      // dataHomeProvider.changeSendedFiles(
      //     newSendedFiles: dataHomeProvider.getSendedFiles + 1);

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

        // dataHomeProvider.changeSendedFiles(
        //     newSendedFiles: dataHomeProvider.getSendedFiles + 1);

        sendDatabase(outputPath, tableName);
      }
    }
    return true;
  }

  Future<void> exportDatabase() async {
    if (isBusy) return;

    await run(() async {
      Database? database = await _databaseRepository.get();

      final script = await database
          !.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');

      final tableNames = script.map((e) => e['name'] as String).toList();
      final files = <String>[];

      emit(DatabaseLoading(tables: tableNames));

      Future.delayed(const Duration(seconds: 30),
          () => emit(DatabaseSuccess(dbPath: state.dbPath)));

      // for (final tableName in tableNames) {
      //   final result = await database.rawQuery('SELECT * FROM $tableName');
      //
      //   if (result.isNotEmpty) {
      //     // dataHomeProvider.changeTotalFiles(
      //     //     newTotalFiles: dataHomeProvider.getTotalFiles + 1);
      //   }
      // }
      //
      // for (final tableName in tableNames) {
      //   final fileName = '${tableName.toLowerCase()}.sql';
      //   final filePath = join(await getDatabasesPath(), fileName);
      //
      //   if (tableName == 'summaries' ||
      //       tableName == 'transactions' ||
      //       tableName == 'locations') {
      //
      //     await exportTableInBatches(database, tableName, filePath);
      //     files.add(fileName);
      //
      //   } else {
      //     await exportTable(database, tableName, filePath);
      //     files.add(fileName);
      //   }
      // }
      //
      // final combinedFile = File(join(await getDatabasesPath(), 'all_tables.sql'));
      // await combinedFile.writeAsString(files.map((f) => 'source $f;\n').join());
    });
  }
}
