import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

//domain
import '../../src/domain/models/isolate.dart';

class HelperFunctions {

  static void heavyTask(IsolateModel model) {
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


}