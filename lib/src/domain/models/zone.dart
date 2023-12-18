const String tableZone = 'zones';

class ZoneFields {
  static final List<String> values = [
    id,
    city,
    departament,
    southwestlat,
    southwestlng,
    northestlat,
    northestlng,
  ];

  static const String id = 'id';
  static const String city = 'city';
  static const String departament = 'departament';
  static const String southwestlat = 'southwestlat';
  static const String southwestlng = 'southwestlng';
  static const String northestlat = 'northestlat';
  static const String northestlng = 'northestlng';
}

class ZoneService {
  ZoneService({
    this.id,
    required this.name,
    required this.departament,
    required this.southwestlat,
    required this.southwestlng,
    required this.northestlat,
    required this.northestlng,
  });

  ZoneService.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    departament = json['departament'];
    southwestlat = json['southwestlat'];
    southwestlng = json['southwestlng'];
    northestlat = json['northestlat'];
    northestlng = json['northestlng'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['departament'] = departament;
    data['southwestlat'] = southwestlat;
    data['southwestlng'] = southwestlng;
    data['northestlat'] = northestlat;
    data['northestlng'] = northestlng;
    return data;
  }

  late int? id;
  late String name;
  late String departament;
  late String southwestlat;
  late String southwestlng;
  late String northestlat;
  late String northestlng;
}
