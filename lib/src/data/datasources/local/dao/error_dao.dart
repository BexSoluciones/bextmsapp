part of '../app_database.dart';

class ErrorDao {
  final AppDatabase _appDatabase;

  ErrorDao(this._appDatabase);

  List<Error> parseErrors(List<Map<String, dynamic>> errorList) {
    final errors = <Error>[];
    for (var errorMap in errorList) {
      final error = Error.fromJson(errorMap);
      errors.add(error);
    }
    return errors;
  }

  Future<List<Error>> getAllErrors() async {
    final db = await _appDatabase.database;
    final errorList = await db!.query(tableErrors);
    final errors = parseErrors(errorList);
    return errors;
  }

  Future<Error?> findError(String zoneId) async {
    final db = await _appDatabase.database;
    final errorList =
    await db!.query(tableErrors, where: 'zone_id = ?', whereArgs: [zoneId]);
    final error = parseErrors(errorList);
    if(error.isEmpty){
      return null;
    }
    return error.first;
  }

  Future<int> insertError(Error error) {
    return _appDatabase.insert(tableErrors, error.toJson());
  }

  Future<int> updateError(Error error) {
    return _appDatabase.update(tableErrors, error.toJson(), 'id', error.id!);
  }

  Future<int> deleteError(Error error){
    return _appDatabase.delete(tableErrors, 'id', error.id!);
  }

  Future<int> deleteAll(int errorId){
    return _appDatabase.delete(tableErrors, 'id', errorId);
  }

  Future<void> insertErrors(List<Error> errors) async {
    final db = await _appDatabase.database;
    var batch = db!.batch();

    if (errors.isNotEmpty) {
      await Future.forEach(errors, (error) async {
        var d = await db.query(tableErrors, where: 'id = ?', whereArgs: [error.id]);
        var w = parseErrors(d);
        if (w.isEmpty) {
          batch.insert(tableErrors, error.toJson());
        } else {
          batch.update(tableErrors, error.toJson(), where: 'id = ?', whereArgs: [error.id]);
        }
      });
    }
    await batch.commit(noResult: true);
    return Future.value();
  }

  Future<void> emptyErrors() async {
    final db = await _appDatabase.database;
    await db!.delete(tableErrors, where: 'id > 0');
    return Future.value();
  }
}
