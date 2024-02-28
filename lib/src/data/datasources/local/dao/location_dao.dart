part of '../app_database.dart';

class LocationDao with FormatDate {
  final AppDatabase _appDatabase;

  LocationDao(this._appDatabase);

  List<Location> parseLocations(List<Map<String, dynamic>> locationList) {
    final locations = <Location>[];
    for (var locationMap in locationList) {
      final location = Location.fromJson(locationMap);
      locations.add(location);
    }
    return locations;
  }

  Future<List<Location>> getAllLocations() async {
    final db = await _appDatabase.database;
    final locationList = await db!.query(tableLocations);
    final locations = parseLocations(locationList);
    return locations;
  }

  Stream<List<Location>> watchAllLocations() async* {
    final db = await _appDatabase.database;
    final locationList = await db!.query(tableLocations);
    final locations = parseLocations(locationList);
    yield locations;
  }

  Future<Location?> getLastLocation() async {
    final db = await _appDatabase.database;

    final locationList =
        await db!.rawQuery('SELECT * FROM locations ORDER BY id desc LIMIT 1');

    final locations = parseLocations(locationList);

    if (locations.isEmpty) {
      return null;
    }

    return locations.first;
  }

  Future<int> insertLocation(Location location) {
    return _appDatabase.insert(tableLocations, location.toJson());
  }

  Future<int> updateLocation(Location location) {
    return _appDatabase.update(
        tableLocations, location.toJson(), 'id', location.id!);
  }

  Future<void> emptyLocations() async {
    final db = await _appDatabase.database;
    await db!.delete(tableLocations);
    return Future.value();
  }

  Future<String> getLocationsToSend() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> results = await db!.query(
      tableLocations,
      where: 'send = 0',
    );

    final formattedResults = results.map((row) {
      return row;
    }).toList();

    final formattedJson = jsonEncode(formattedResults);
    return formattedJson;
  }

  Future<bool> countLocationsManager() async {
    final db = await _appDatabase.database;

    var result = await db?.rawQuery('''
      SELECT COUNT(*) FROM $tableLocations WHERE send = 0
    ''');

    if (result != null && result.isNotEmpty) {
      var count = Sqflite.firstIntValue(result)!;
      if (count >= 7) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  }

  Future<int?> updateLocationsManager() async {
    final db = await _appDatabase.database;
    return await db?.update(tableLocations, {'send': 1}, where: 'send = 0');
  }

  Future<int> deleteLocationsByDays() async {
    final db = await _appDatabase.database;
    var today = DateTime.now();
    var limitDaysWork = _storageService.getInt('limit_days_works') ?? 0;
    var datesToValidate = today.subtract(Duration(days: limitDaysWork));
    List<Map<String, dynamic>> locationToDelete;

    var formattedToday = DateTime(today.year, today.month, today.day);
    var formattedDatesToValidate = DateTime(
        datesToValidate.year, datesToValidate.month, datesToValidate.day);
    var formattedDateString =
        formattedDatesToValidate.toIso8601String().split('T')[0];

    locationToDelete = await db!.query(
      tableLocations,
      where: 'substr("%Y-%m-%d", time) <= ?',
      whereArgs: [formattedDateString],
    );

    for (var task in locationToDelete) {
      var createdAt = DateTime.parse(task['time']);
      var differenceInDays = formattedToday.difference(createdAt).inDays;
      if (differenceInDays > limitDaysWork) {
        await db.delete(
          tableLocations,
          where: 'id = ?',
          whereArgs: [task['id']],
        );
      }
    }

    return db.delete(
      tableLocations,
      where: 'substr("%Y-%m-%d", time) <= ?',
      whereArgs: [formattedDateString],
    );
  }
}
