import 'package:bexdeliveries/src/locator.dart';
import 'package:bexdeliveries/src/presentation/blocs/processing_queue/processing_queue_bloc.dart';
import 'package:bexdeliveries/src/services/storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';


//widgets
import '../domain/repositories/database_repository.dart';

final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();
final LocalStorageService _storageService = locator<LocalStorageService>();
final ProcessingQueueBloc _processingQueueBloc = locator<ProcessingQueueBloc>();

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





}