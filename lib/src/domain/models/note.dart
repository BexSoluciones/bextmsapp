const String tableNotes = 'notes';

class NoteFields {
  static late List<String> values = [
    id,
    latitude,
    longitude,
    observation,
    images,
    zoneId
  ];

  static const String id = 'id';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String observation = 'observation';
  static const String images = 'images';
  static const String zoneId = 'zone_id';
}

class Note {
  int? id;
  late double latitude;
  late double longitude;
  late String observation;
  List<String>? images;
  int? zoneId;

  Note({
    required this.latitude,
    required this.longitude,
    required this.observation,
    required this.images,
    zoneId,
  });

  Note.fromJson(Map<String, dynamic> json){
    id = json['id'];
    latitude = json['latitude'] is String ? double.parse(json['latitude']) : json['latitude'];
    longitude = json ['longitude'] is String ? double.parse(json['longitude']) : json['longitude'];
    observation = json['observation'];
    images = json['images'];
    zoneId = json['zone_id'];
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'observation': observation,
      'images': images,
      'zone_id': zoneId
    };
  }

}