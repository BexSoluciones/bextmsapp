import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:location_repository/location_repository.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:location/location.dart' as loc;

//domain
import '../../src/domain/models/work.dart';

//widgets
import '../../src/domain/repositories/database_repository.dart';
import '../../src/presentation/widgets/show_map_direction_widget.dart';

//locator
import '../../src/locator.dart';
import '../../src/services/storage.dart';
import '../../src/services/navigation.dart';

final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();
final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();
final LocationRepository _locationRepository = locator<LocationRepository>();

class HelperFunctions {
  loc.Location location = loc.Location();

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
      CurrentUserLocationEntity? location) async {
    final availableMaps = await MapLauncher.installedMaps;

    location ??= await _locationRepository.getCurrentLocation();

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


  Future<void> showMapDirectionWaze(BuildContext context, Work work,
      CurrentUserLocationEntity? location) async {
    final availableMaps = await MapLauncher.installedMaps;
    AvailableMap? waze;

    location ??= await _locationRepository.getCurrentLocation();

    for (final map in availableMaps) {
      if (map.mapType == MapType.waze) {
        waze = map;
        break;
      }
    }

    if (waze != null) {
      await waze.showDirections(
        destination: Coords(
          double.parse(work.latitude!),
          double.parse(work.longitude!),
        ),
        destinationTitle: work.customer,
        origin: Coords(location.latitude, location.longitude),
        originTitle: 'Origen',
        waypoints: null,
        directionsMode: DirectionsMode.driving,
      );
    } else {
      print('Waze no está instalado en el dispositivo.');
    }
  }


  Future<void> initLocationService() async {
    final bool serviceEnabled = await checkAndEnableLocationService();
    if (!serviceEnabled) {
      await location.enableBackgroundMode(enable: false);
      return;
    }

    final loc.PermissionStatus permissionStatus =
        await checkAndRequestLocationPermission();
    if (permissionStatus != loc.PermissionStatus.granted) {
      await location.enableBackgroundMode(enable: false);
      return;
    }

    await location.enableBackgroundMode(enable: true);
  }

  Future<bool> checkAndEnableLocationService() async {
    final bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      final bool requestedService = await location.requestService();
      if (!requestedService) {
        return false;
      }
    }
    return true;
  }

  Future<loc.PermissionStatus> checkAndRequestLocationPermission() async {
    loc.PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus;
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
    //   List<Work>? w = [];
    //   w = await _apiRepository.routing(historyId, workcode, queue);
    //
    //   if (w != null) {
    //     await database.insertWorks(w);
    //     _storageService.setBool('$workcode-routing', false);
    //   } else {
    //     queue.task = 'error';
    //     queue.error = 'routing not found.';
    //   }
    //
    //   var updateHoBody = jsonDecode(queue.body);
    //
    //   bool? historyOrder;
    //   historyOrder = await repository.updateHistoryOrder(
    //       updateHoBody['workcode'], updateHoBody['count'], queue);
    //   if (historyOrder != null) {
    //     queue.task = 'done';
    //   } else {
    //     queue.task = 'error';
    //     queue.error = 'historyOrder Null';
    //   }
  }

  Future<void> useHistoric(
    String workcode,
    int historyId,
  ) async {
    // final queueBloc = BlocProvider.of<QueueBloc>(
    //     _navigationService.navigatorKey.currentState!.overlay!.context);
    // var processingQueue = ProcessingQueue(
    //     body: jsonEncode({'workcode': workcode, 'history_id': historyId}),
    //     task: 'incomplete',
    //     code: 'store_post_routing',
    //     created_at: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    //     location: null);
    //
    // queueBloc.add(AddTaskEvent(processingQueue));
    // var processingQueue2 = ProcessingQueue(
    //     body: jsonEncode({'workcode': workcode, 'count': 1}),
    //     task: 'incomplete',
    //     code: 'store_history_used',
    //     created_at: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    //     location: null);
    //
    // queueBloc.add(AddTaskEvent(procesingQueue2));
    // _storageService.setBool('$workcode-routing', true);
    // _storageService.setBool('$workcode-historic', true);
  }
}
