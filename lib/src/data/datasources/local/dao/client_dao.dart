part of '../app_database.dart';

class ClientDao {
  final AppDatabase _appDatabase;

  ClientDao(this._appDatabase);

  List<Client> parseClients(List<Map<String, dynamic>> clientList) {
    final clients = <Client>[];
    for (var clientMap in clientList) {
      final client = Client.fromJson(clientMap);
      clients.add(client);
    }
    return clients;
  }

  Future<List<Client>> getAllClients() async {
    final db = await _appDatabase.database;
    final clientList = await db!.query(tableClients);
    final clients = parseClients(clientList);
    return clients;
  }

  Future<bool> validateClient(int id) async {
    final db = await _appDatabase.database;
    final clientList =
        await db!.query(tableClients, where: 'id = ?', whereArgs: [id]);
    final clients = parseClients(clientList);
    return clients.isNotEmpty;
  }

  Stream<List<Client>> watchAllClients() async* {
    final db = await _appDatabase.database;
    final clientList = await db!.query(tableClients);
    final clients = parseClients(clientList);
    yield clients;
  }

  Future<int> insertClient(Client client) {
    return _appDatabase.insert(tableClients, client.toJson());
  }

  Future<int> updateClient(Client client) {
    return _appDatabase.update(tableClients, client.toJson(), 'id', client.id!);
  }

  Future<void> emptyClients() async {
    final db = await _appDatabase.database;
    await db!.delete(tableClients);
    return Future.value();
  }
}
