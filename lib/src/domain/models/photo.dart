const String tablePhotos = 'photos';

class PhotoFields {
  static final List<String> values = [
    id,
    name,
    path,
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String path = 'path';
}

class Photo{
  int? id;
  late String name;
  late String path;

  Photo({this.id, required this.name,required this.path});

  Photo.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    path = json ['path'];
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'path': path,
    };
  }
}