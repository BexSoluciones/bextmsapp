import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:core' hide Error;
import 'package:bexdeliveries/src/presentation/blocs/gps/gps_bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:yaml/yaml.dart';

//blocs
import '../../src/domain/models/requests/login_request.dart';
import '../../src/presentation/blocs/processing_queue/processing_queue_bloc.dart';

//domain
import '../../src/domain/models/processing_queue.dart';
import '../../src/domain/models/work.dart';
import '../../src/domain/models/error.dart';
import '../../src/domain/models/requests/history_order_updated_request.dart';
import '../../src/domain/models/requests/routing_request.dart';
import '../../src/domain/abstracts/format_abstract.dart';
import '../../src/domain/repositories/database_repository.dart';
import '../../src/domain/repositories/api_repository.dart';

//utils
import '../../src/utils/constants/colors.dart';
import '../../src/utils/constants/strings.dart';
import '../../src/utils/resources/data_state.dart';

//widgets
import '../../src/presentation/widgets/show_map_direction_widget.dart';
import '../../src/presentation/widgets/custom_dialog.dart';
import '../../src/presentation/widgets/update_dialog_widget.dart';

//locator
import '../../src/locator.dart';
import '../../src/services/storage.dart';
import '../../src/services/navigation.dart';
import '../../src/services/logger.dart';

final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();
final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();
final ApiRepository _apiRepository = locator<ApiRepository>();

class HelperFunctions with FormatDate {
  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    const storage = FlutterSecureStorage();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      var id = await storage.read(key: 'unique_id');
      var model = iosDeviceInfo.utsname.machine;
      if (id != null) {
        return {'id': id, 'model': model};
      } else {
        id = iosDeviceInfo.identifierForVendor!;
        await storage.write(key: 'unique_id', value: id);
        return {'id': id, 'model': model};
      }
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      var id = await storage.read(key: 'unique_id');
      var model = androidDeviceInfo.model;
      if (id != null) {
        return {'id': id, 'model': model};
      } else {
        id = androidDeviceInfo.id;
        await storage.write(key: 'unique_id', value: id);
        return {'id': id, 'model': model};
      }
    }
    return null;
  }

  Future<void> login() async {
    var username = _storageService.getString('username');
    var password = _storageService.getString('password');

    var response = await _apiRepository.login(
        request: LoginRequest(
      username!,
      password!,
    ));

    if (response is DataSuccess) {
      final login = response!.data!.login;
      _storageService.setString('token', login.token);
    } else {
      logDebug(headerDeveloperLogger, response!.error!);
    }
  }

  Future<FirebaseRemoteConfig> setupRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    RemoteConfigValue(null, ValueSource.valueStatic);
    return remoteConfig;
  }

  void versionCheck(context) async {
    final isConnected = await checkConnection();
    if (isConnected) {
      var yaml = loadYaml(await rootBundle.loadString('pubspec.yaml'));
      var currentVersion = double.parse(
          yaml['version'].trim().replaceAll('.', '').split('+')[0]);

      //Get Latest version info from firebase config
      final remoteConfig = await setupRemoteConfig();

      try {
        // Using default duration to force fetching from remote server.
        await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 0),
          minimumFetchInterval: Duration.zero,
        ));
        await remoteConfig.fetchAndActivate();

        var force = remoteConfig.getBool('force_activate');
        var forceUpdate = remoteConfig.getBool('force_update');
        var message = remoteConfig.getString('message');

        var newVersion = double.parse(remoteConfig
            .getString('force_update_current_version')
            .trim()
            .replaceAll('.', ''));

        if (force && newVersion > currentVersion) {
          await UpdateDialog(skipUpdate: forceUpdate, message: message)
              .showVersionDialog(context);
        }
      } on PlatformException catch (exception, stackTrace) {
        await handleException(exception, stackTrace);
      } catch (exception, stackTrace) {
        await handleException(exception, stackTrace);
      }
    }
  }

  Future<void> handleException(dynamic error, StackTrace stackTrace) async {
    var errorData = Error(
      errorMessage: error.toString(),
      stackTrace: stackTrace.toString(),
      createdAt: now(),
    );
    await _databaseRepository.insertError(errorData);
    await FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get _externalPath async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  Stream<int> countImages(orderNumber) async* {
    var path = await _localPath;

    var directory = Directory('$path/$orderNumber/');

    if (directory.existsSync()) {
      var fileList =
          directory.listSync().map((item) => item.path).toList(growable: false);

      yield fileList.length;

      // Listen for file system events and update count on create and delete
      var watcher = directory.watch();
      await for (var event in watcher) {
        if (event.type == FileSystemEvent.create ||
            event.type == FileSystemEvent.delete) {
          var fileList = directory
              .listSync()
              .map((item) => item.path)
              .toList(growable: false);

          yield fileList.length;
        }
      }
    } else {
      yield 0;
    }
  }

  Future<int> countImagesSync(orderNumber) async {
    var path = await _localPath;

    var directory = Directory('$path/$orderNumber/');

    if (directory.existsSync()) {
      var imageList = directory
          .listSync()
          .map((item) => item.path)
          .where((item) => item.endsWith('.jpg'))
          .toList(growable: false);
      return imageList.length;
    } else {
      return 0;
    }
  }

  Future<List<File>> getImages(orderNumber) async {
    var images = <File>[];
    var path = await _localPath;
    path = path.replaceFirst('app_flutter', '');
    var directory = Directory('$path/cache/');
    if (directory.existsSync()) {
      var imageList = directory
          .listSync()
          .map((item) => item.path)
          .where((item) => item.endsWith('.jpg'))
          .toList(growable: false);

      for (var element in imageList) {
        var file = File(element);
        images.add(file);
      }
      return images;
    } else {
      return [];
    }
  }

  Future<File?> getFirm(folder) async {
    File? file;
    var path = await _externalPath;

    var directory = Directory('$path/$folder/');

    if (directory.existsSync()) {
      var imageList = directory
          .listSync()
          .map((item) => item.path)
          .where((item) => item.endsWith('.png'))
          .toList(growable: false);

      if (imageList.isNotEmpty) {
        file = File(imageList[0]);
      }

      return file;
    } else {
      return null;
    }
  }

  Future<Directory> directoryFirm(folder) async {
    var path = await _externalPath;
    return Directory('$path/$folder/');
  }

  Future<void> moveImages(folder) async {
    var localPath = await _localPath;
    var newDirectory = await Directory('$localPath/$folder').create();

    var path = await _localPath;

    var directory = Directory(path);

    var imageList = directory
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith('.jpg'))
        .toList(growable: false);

    Future.forEach(imageList, (element) {
      var file = File(element);
      file.rename(newDirectory.path);
    });
  }

  Future<void> deleteImages(folder) async {
    var path = await _localPath;
    path = path.replaceFirst('app_flutter', '');
    var directory = Directory('$path/cache');
    if (directory.existsSync()) {
      var imageList = directory
          .listSync()
          .map((item) => item.path)
          .where((item) => item.endsWith('.jpg') || item.endsWith('.png'))
          .toList(growable: false);
      for (int index = 0; index < imageList.length; index++) {
        var element = imageList[index];
        var file = File(element);
        await _databaseRepository.deleteAll(index + 1);
        await file.delete();
      }
    }
  }

  Future<void> deleteFirm(folder) async {
    var path = await _localPath;

    var directory = Directory('$path/$folder');

    if (directory.existsSync()) {
      var imageList = directory
          .listSync()
          .map((item) => item.path)
          .where((item) => item.endsWith('.jpg'))
          .toList(growable: false);

      imageList.map((element) async {
        var file = File(element);
        await file.delete();
      });
    }
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      return Future.value(null);
    }
  }

  void main(dirPath) {
    final dir = Directory(dirPath);
    dir.deleteSync(recursive: true);
  }

  Future<void> launchWhatsApp(String phone, String message) async {
    try {
      final link = WhatsAppUnilink(
        phoneNumber: phone,
        text: message,
      );
      await FlutterWebBrowser.openWebPage(url: link.toString());
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      return;
    }
  }

  Future<void> saveFirm(
    String folder,
    String fileName,
    ByteData image,
  ) async {
    var directory = await getExternalStorageDirectory();
    var path = directory!.path;
    await Directory('$path/$folder').create(recursive: true);

    File('$path/$folder/$fileName.png')
        .writeAsBytesSync(image.buffer.asInt8List());
  }

  Future<Widget?> showMapDirection(BuildContext context, Work work,
      LatLng? location) async {
    final availableMaps = await MapLauncher.installedMaps;

    // TODO [Andres Cardenas] get one location ///TEST
    if(context.mounted) location ??= context.read<GpsBloc>().state.lastKnownLocation;

    if (availableMaps.length == 1) {
      await availableMaps.first.showDirections(
        destination: Coords(
          double.parse(work.latitude!),
          double.parse(work.longitude!),
        ),
        destinationTitle: work.customer,
        origin: Coords(location!.latitude, location.longitude),
        originTitle: 'Origen',
        waypoints: null,
        directionsMode: DirectionsMode.driving,
      );

      return null;
    } else {
      if (context.mounted) {
        return await MapsSheet.show(
            context: context,
            onMapTap: (map) {
              map.showDirections(
                destination: Coords(
                  double.parse(work.latitude!),
                  double.parse(work.longitude!),
                ),
                destinationTitle: work.customer,
                origin: Coords(location!.latitude, location.longitude),
                originTitle: 'Origen',
                waypoints: null,
                directionsMode: DirectionsMode.driving,
              );
            });
      } else {
        return null;
      }
    }
  }

   Future<void> initLocationService() async {
     final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
     if (!serviceEnabled) {
       return;
     }

     LocationPermission permission = await Geolocator.checkPermission();
     if (permission == LocationPermission.denied) {
       permission = await Geolocator.requestPermission();
       if (permission == LocationPermission.denied) {
         return Future.error('Location permissions are denied');
       }
     }

     if (permission == LocationPermission.deniedForever) {
       return Future.error(
           'Location permissions are permanently denied, we cannot request permissions.');
     }
   }

   Future<bool> checkAndEnableLocationService() async {
     final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
     if (!serviceEnabled) {
       final bool requestedService = await Geolocator.openLocationSettings();
       if (!requestedService) {
         return false;
       }
     }
     return true;
   }

   Future<LocationPermission> checkAndRequestLocationPermission() async {
     LocationPermission permission = await Geolocator.checkPermission();
     if (permission == LocationPermission.denied) {
       permission = await Geolocator.requestPermission();
       if (permission == LocationPermission.denied) {
         return Future.error('Location permissions are denied');
       }
     }
     return permission;
   }

  Future<bool> deleteWorks(Work work) async {
    var dob = DateTime.parse(work.date!);
    var dur = DateTime.now().difference(dob);
    if (dur.inDays > _storageService.getInt('limit_days_works')! &&
        work.status == 'complete') {
      await _databaseRepository.deleteTransactionsByWorkcode(work.workcode!);
      await _databaseRepository.deleteSummariesByWorkcode(work.workcode!);
      await _databaseRepository.deleteWorksByWorkcode(work.workcode!);
      return true;
    } else {
      return false;
    }
  }

  Future<void> useHistoricFromSync(
      {required String workcode,
      required int historyId,
      required var queue}) async {
    final responseR = await _apiRepository.routing(
        request: RoutingRequest(historyId, workcode));

    if (responseR is DataSuccess) {
      if (responseR.data!.works.isNotEmpty) {
        await _databaseRepository.insertWorks(responseR.data!.works);
        _storageService.setBool('$workcode-routing', false);
      } else {
        queue.task = 'error';
        queue.error = 'routing not found.';
      }
    }

    var updateHoBody = jsonDecode(queue.body);
    final responseH = await _apiRepository.historyOrderUpdated(
        request: HistoryOrderUpdatedRequest(workcode, updateHoBody['count']));
    if (responseH is DataSuccess) {
      queue.task = 'done';
    } else {
      queue.task = 'error';
      queue.error = 'historyOrder Null';
    }
  }

  Future<void> useHistoric(
    String workcode,
    int historyId,
  ) async {
    final queueBloc = BlocProvider.of<ProcessingQueueBloc>(
        _navigationService.navigatorKey.currentState!.overlay!.context);
    var processingQueue = ProcessingQueue(
      body: jsonEncode({'workcode': workcode, 'history_id': historyId}),
      task: 'incomplete',
      code: 'store_post_routing',
      createdAt: now(),
      updatedAt: now(),
    );

    queueBloc.add(ProcessingQueueAdd(processingQueue: processingQueue));

    var processingQueue2 = ProcessingQueue(
      body: jsonEncode({'workcode': workcode, 'count': 1}),
      task: 'incomplete',
      code: 'store_history_used',
      createdAt: now(),
      updatedAt: now(),
    );

    queueBloc.add(ProcessingQueueAdd(processingQueue: processingQueue2));
    _storageService.setBool('$workcode-routing', true);
    _storageService.setBool('$workcode-historic', true);
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  double calculateDistanceInMetersGeo(
      LatLng currentLocation, double lat, double long) {
    const earthRadius = 6371.0;
    var lat1 = currentLocation.latitude;
    var lon1 = currentLocation.longitude;
    var lat2 = lat;
    var lon2 = long;
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    var distanceInKilometers = earthRadius * c;
    var distanceInMeters = distanceInKilometers * 1000;

    return distanceInMeters;
  }

  bool isWithinRadiusGeo(
      LatLng currentLocation, double lat, double long, int ratio) {
    const earthRadius = 6371.0;
    final radiusInMeters = ratio; // Radio en metros
    var lat1 = currentLocation.latitude;
    var lon1 = currentLocation.longitude;
    var lat2 = lat;
    var lon2 = long;
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    var c = 2 * asin(sqrt(a));
    var distanceInMeters = earthRadius * c * 1000;

    return distanceInMeters <= radiusInMeters;
  }

  void showDialogWithDistance(
      BuildContext context, double distanceInMeters, int ratio) async {
    String distanceRemaining;
    distanceInMeters = distanceInMeters - ratio.toDouble();
    if (distanceInMeters < 1000) {
      distanceRemaining = '${distanceInMeters.round()} metros';
    } else {
      var distanceInKilometers = distanceInMeters / 1000;
      distanceRemaining = '${distanceInKilometers.toStringAsFixed(2)} km';
    }

    await showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'No has llegado a la zona',
        message: 'Te hacen falta: $distanceRemaining',
        elevatedButton1: kPrimaryColor,
        elevatedButton2: Colors.green,
        cancelarButtonText: '',
        completarButtonText: 'Aceptar',
        icon: Icons.map,
        colorIcon: kPrimaryColor,
      ),
    );
  }
}
