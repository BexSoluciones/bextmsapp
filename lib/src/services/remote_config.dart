import 'package:firebase_remote_config/firebase_remote_config.dart';


class RemoteConfigService {
  static RemoteConfigService? _instance;
  static FirebaseRemoteConfig? _remoteConfig;

  static RemoteConfigSettings? settings;

  static Future<RemoteConfigService?> getInstance() async {
    _instance ??= RemoteConfigService();
    _remoteConfig = FirebaseRemoteConfig.instance;
    return _instance;
  }

  bool _initialized = false;

  Future init() async {
    if(!_initialized){
      await _remoteConfig?.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 1),
          minimumFetchInterval: const Duration(seconds: 1)));

      await _remoteConfig?.fetchAndActivate();
    }

    _initialized = true;
  }

  String? getString(String value) {
    return _remoteConfig?.getString(value);
  }

  bool? getBool(String value) {
    return _remoteConfig?.getBool(value);
  }

}