import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

//repositories
import '../../domain/repositories/database_repository.dart';

//domain
import '../../domain/models/photo.dart';

class PhotoProvider {

  final DatabaseRepository databaseRepository;

  PhotoProvider({ required this.databaseRepository }) : super();

  Future<String> getPath() async{
    return join((await getTemporaryDirectory()).path, '${DateTime.now()}.png',);
  }

  Future<List<Photo>> loadPhotos() async {
    return await databaseRepository.getAllPhotos();
  }

  Future<int> addPhoto(Photo photo) async {
    return await databaseRepository.insertPhoto(photo);
  }

  Future<int> deletePhoto(Photo photo) async {
    return await databaseRepository.deletePhoto(photo);
  }
}