import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static LocalStorageService? _instance;

  static Future<LocalStorageService?> getInstance() async {
    _instance ??= LocalStorageService();
    SharedPreferences.setMockInitialValues({});
    return _instance;
  }
}
