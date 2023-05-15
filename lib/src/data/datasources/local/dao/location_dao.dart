part of '../app_database.dart';

class LocationDao {
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
    final db = await _appDatabase.streamDatabase;
    final locationList = await db!.query(tableLocations);
    final locations = parseLocations(locationList);
    return locations;
  }

  Stream<List<Location>> watchAllLocations() async* {
    final db = await _appDatabase.streamDatabase;
    final locationList = await db!.query(tableLocations);
    final locations = parseLocations(locationList);
    yield locations;
  }

  Future<Location?> getLastLocation() async {
    final db = await _appDatabase.streamDatabase;

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
    final db = await _appDatabase.streamDatabase;
    await db!.delete(tableLocations);
    return Future.value();
  }
}
