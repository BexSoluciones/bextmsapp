import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  static Future<LocalStorageService?> getInstance() async {
    _instance ??= LocalStorageService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance;
  }

  String? getString(key) {
    if (_preferences == null) return null;
    return _preferences!.getString(key);
  }

  Map<String, dynamic>? getObject(key) {
    if (_preferences == null) return null;
    final objectString = _preferences?.getString(key);
    if (objectString != null) {
      return const JsonDecoder().convert(objectString);
    }
    return null;

  }

  int? getInt(key) {
    if (_preferences == null) return null;
    return _preferences!.getInt(key);
  }

  double? getDouble(key) {
    if (_preferences == null) return null;
    return _preferences!.getDouble(key);
  }

  bool? getBool(key) {
    if (_preferences == null) return null;
    return _preferences!.getBool(key);
  }

  void setString(key, value) {
    if (_preferences == null) return;
    if(value == null) return;
    _preferences!.setString(key, value);
  }

  void setObject(key, object){
    if(_preferences == null) return;
    if(object == null) return;
    final string = const JsonEncoder().convert(object);
    _preferences?.setString(key, string);
  }

  void setInt(key, value) {
    if (_preferences == null) return;
    if(value == null) return;
    _preferences!.setInt(key, value);
  }

  void setDouble(key, value) {
    if (_preferences == null) return;
    if(value == null) return;
    _preferences!.setDouble(key, value);
  }

  void setBool(key, value) {
    if (_preferences == null) return;
    if(value == null) return;
    _preferences!.setBool(key, value);
  }

  void remove(key) {
    if(_preferences == null) return;
    _preferences!.remove(key);
  }

  Future<void> clear() async {
    if (_preferences == null) return;
    await _preferences!.clear();
  }
}
