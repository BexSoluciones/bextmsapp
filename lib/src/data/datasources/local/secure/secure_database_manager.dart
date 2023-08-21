import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//core
import '../core/primitive_database.dart';
import '../core/primitive_keys.dart';

//utils
import '../../../../utils/extensions/string_extension.dart';

class SecureDatabaseManager extends PrimitiveDatabase {
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<T?> read<T>(PrimitiveKeys key) async {
    final response = await _secureStorage.read(key: key.name);
    if (response == null || response.isEmpty) return null;
    return response.item<T>();
  }

  @override
  Future<bool> write<T>({required PrimitiveKeys key, required T data}) async {
    await _secureStorage.write(key: key.name, value: data.toString());
    // todo: check write success
    return true;
  }
}