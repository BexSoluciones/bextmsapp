part of '../app_database.dart';

class PhotoDao {
  final AppDatabase _appDatabase;

  PhotoDao(this._appDatabase);

  List<Photo> parsePhotos(List<Map<String, dynamic>> photoList) {
    final photos = <Photo>[];
    for (var photoMap in photoList) {
      final photo = Photo.fromJson(photoMap);
      photos.add(photo);
    }
    return photos;
  }

  Future<List<Photo>> getAllPhotos() async {
    final db = await _appDatabase.database;
    final photoList = await db!.query(tablePhotos);
    final photos = parsePhotos(photoList);
    return photos;
  }

  Future<Photo?> findPhoto(String path) async {
    final db = await _appDatabase.database;
    final photoList =
    await db!.query(tablePhotos, where: 'path = ?', whereArgs: [path]);
    final photo = parsePhotos(photoList);
    if(photo.isEmpty){
      return null;
    }
    return photo.first;
  }

  Future<int> insertPhoto(Photo photo) {
    return _appDatabase.insert(tablePhotos, photo.toJson());
  }

  Future<int> updatePhoto(Photo photo) {
    return _appDatabase.update(tablePhotos, photo.toJson(), 'id', photo.id!);
  }

  Future<int> deletePhoto(Photo photo){
    return _appDatabase.delete(tablePhotos, 'id', photo.id!);
  }

  Future<int> deleteAll(int photoId){
    return _appDatabase.deleteIma(tablePhotos);
  }

  Future<void> insertPhotos(List<Photo> photos) async {
    final db = await _appDatabase.database;
    var batch = db!.batch();

    if (photos.isNotEmpty) {
      await Future.forEach(photos, (photo) async {
        var d = await db.query(tablePhotos, where: 'id = ?', whereArgs: [photo.id]);
        var w = parsePhotos(d);
        if (w.isEmpty) {
          batch.insert(tablePhotos, photo.toJson());
        } else {
          batch.update(tablePhotos, photo.toJson(), where: 'id = ?', whereArgs: [photo.id]);
        }
      });
    }
    await batch.commit(noResult: true);
    return Future.value();
  }

  Future<void> emptyPhotos() async {
    final db = await _appDatabase.database;
    await db!.delete(tablePhotos, where: 'id > 0');
    return Future.value();
  }
}
