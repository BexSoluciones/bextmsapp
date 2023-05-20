import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:location_repository/location_repository.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:path_provider/path_provider.dart';

//domain
import '../../src/domain/models/isolate.dart';
import '../../src/domain/models/work.dart';

//widgets
import '../../src/presentation/widgets/show_map_direction_widget.dart';

class HelperFunctions {

  void heavyTask(IsolateModel model) {
    for (var i = 0; i < model.iteration; i++) {
      model.functions[i];
    }
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

    var directory = Directory('$path/$orderNumber/');
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

    var directory = Directory('$path/$folder');

    if (directory.existsSync()) {
      var imageList = directory
          .listSync()
          .map((item) => item.path)
          .where((item) => item.endsWith('.jpg'))
          .toList(growable: false);

      for (var element in imageList) {
        var file = File(element);
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
    } catch (e) {
      return Future.value(null);
    }
  }

  void main(dirPath) {
    final dir = Directory(dirPath);
    dir.deleteSync(recursive: true);
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

  Future<Widget?> showMapDirection(BuildContext context, Work work, CurrentUserLocationEntity location) async {

    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.length == 1) {
      await availableMaps.first.showDirections(
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

      return null;
    } else {
      if(context.mounted){
        return await MapsSheet.show(
            context: context,
            onMapTap: (map) {
              map.showDirections(
                destination: Coords(
                  double.parse(work.latitude!),
                  double.parse(work.longitude!),
                ),
                destinationTitle: work.customer,
                origin:
                Coords(location.latitude, location.longitude),
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

}