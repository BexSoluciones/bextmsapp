//core
import 'package:bexdeliveries/src/services/location.dart';
import 'package:flutter/foundation.dart';

import '../../core/helpers/index.dart';
import '../../core/helpers/pausable_timer.dart';

//services
import '../locator.dart';
import 'storage.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final LocationService _locationService = locator<LocationService>();
final helperFunctions = HelperFunctions();

class TimerService {

  static TimerService? _instance;
  late PausableTimer timer;

  static Future<TimerService?> getInstance() async {
    _instance ??= TimerService();
    return _instance;
  }

  void start() {

    timer = PausableTimer(Duration(minutes: _storageService.getInt('frequency') ?? 1), () async {

      if(_storageService.getBool('timer_is_active') == true){

        await setLocation();

        if(_storageService.getBool('cancel')! && timer.isPaused == false){
          timer.pause();
        } else if(_storageService.getInt('frequency') != null && _storageService.getInt('frequency') != timer.duration.inMinutes){
          timer..cancel()..start();
        } else if(timer.tick >= 1 && timer.isExpired == true && timer.isCancelled == false && timer.isActive == false && timer.duration > Duration.zero){
          timer..reset()..start();
        }
      }

    });

  }

  bool restart() {
    if(_storageService.getInt('frequency') != null && timer.isActive){
      _storageService.setBool('timer_is_active', true);
      timer..reset()..start();
      return true;
    } else {
      return false;
    }
  }

  bool active() {
    if(timer.isActive == false && timer.elapsed == Duration.zero){
      _storageService.setBool('timer_is_active', true);
      timer.start();
      return true;
    }  else {
      return false;
    }
  }

  Future<void> setLocation() async {
    try {
      var isWalking = _storageService.getBool('is_walking');
      var frequency = _storageService.getInt('frequency');

      if (isWalking != null && isWalking) {
        _storageService.setInt('frequency', 1);
      } else {
        _storageService.setInt('frequency', 5);
      }

      if (frequency != null && frequency == 1) {
        _locationService.saveLocation('walking');
      } else {
        _locationService.saveLocation('location');
      }
    } catch (error) {
      if (kDebugMode) {
        print('error aqui');
        print('error ---- $error');
      }
    }

    return Future.value(null);
  }



}