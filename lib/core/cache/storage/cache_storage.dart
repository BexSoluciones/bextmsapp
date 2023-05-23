import 'storage.dart';
// import 'package:hive/hive.dart';

//TODO:: change to isar database

import '../../../src/locator.dart';
import '../../../src/services/storage.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class CacheStorage implements Storage {
  static const _boxName = "cache";

  CacheStorage();

  @override
  Future<void> clear({String? prefix}) async {
    if (prefix == null) {
      await _storageService.clear();
    } else {
      final box = _storageService.getObject(prefix);
      for (var key in box!.keys) {
        if (key.startsWith(prefix)) {
          _storageService.remove(key);
        }
      }
    }
  }

  @override
  Future<void> delete(String key) async {
    return _storageService.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    return _storageService.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    return _storageService.setString(key, value);
  }

  @override
  Future<int> count({String? prefix}) async {
    final box = _storageService.getObject(prefix);
    if (prefix == null) {
      return box!.length;
    } else {
      var count = 0;
      for (var key in box!.keys) {
        if (key.startsWith(prefix)) {
          count++;
        }
      }
      return count;
    }
  }
}