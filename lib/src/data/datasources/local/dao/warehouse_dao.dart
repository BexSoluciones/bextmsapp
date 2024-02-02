part of '../app_database.dart';

class WarehouseDao {
  final AppDatabase _appDatabase;

  WarehouseDao(this._appDatabase);

  List<Warehouse> parseWarehouses(List<Map<String, dynamic>> warehouseList) {
    final warehouses = <Warehouse>[];
    for (var warehouseMap in warehouseList) {
      final warehouse = Warehouse.fromJson(warehouseMap);
      warehouses.add(warehouse);
    }
    return warehouses;
  }

  Future<List<Warehouse>> getAllWarehouses() async {
    final db = await _appDatabase.database;
    final warehouseList = await db!.query(tableWarehouses);
    final warehouses = parseWarehouses(warehouseList);
    return warehouses;
  }

  Future<Warehouse?> findWarehouse(int id) async {
    final db = await _appDatabase.database;
    final warehouseList =
        await db!.query(tableWarehouses, where: 'id = ?', whereArgs: [id]);
    final warehouses = parseWarehouses(warehouseList);
    if (warehouses.isEmpty) {
      return null;
    }
    return warehouses.first;
  }

  Future<int> insertWarehouse(Warehouse warehouse) {
    return _appDatabase.insert(tableWarehouses, warehouse.toJson());
  }

  Future<int> updateWarehouse(Warehouse warehouse) {
    return _appDatabase.update(
        tableWarehouses, warehouse.toJson(), 'id', warehouse.id!);
  }

  Future<void> insertWarehouses(List<Warehouse> warehouses) async {
    final db = await _appDatabase.database;
    var batch = db!.batch();

    if (warehouses.isNotEmpty) {
      await Future.forEach(warehouses, (warehouse) async {
        var d = await db.query(tableWarehouses,
            where: 'id = ?', whereArgs: [warehouse.id]);
        var w = parseWarehouses(d);
        if (w.isEmpty) {
          batch.insert(tableWarehouses, warehouse.toJson());
        } else {
          batch.update(tableWarehouses, warehouse.toJson(),
              where: 'id = ?', whereArgs: [warehouse.id]);
        }
      });
    }
    await batch.commit(noResult: true);
    return Future.value();
  }

  Future<void> emptyWarehouses() async {
    final db = await _appDatabase.database;
    await db!.delete(tableWarehouses, where: 'id > 0');
    return Future.value();
  }
}
