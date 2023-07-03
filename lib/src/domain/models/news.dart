import 'dart:convert';

News newsFromJson(String str) => News.fromJson(json.decode(str));

String newsToJson(News data) => json.encode(data.toJson());

const String tableNews = 'news';

class NewsFields {
  static final List<String> values = [
    id,
    userId,
    workId,
    summaryId,
    status,
    nommotvis,
    codmotvis,
    latitude,
    longitude,
    images,
    firm,
    observation,
    createdAt,
    updatedAt
  ];

  static const String id = 'id';
  static const String userId = 'user_id';
  static const String workId = 'work_id';
  static const String summaryId = 'summary_id';
  static const String status = 'status';
  static const String nommotvis = 'nommotvis';
  static const String codmotvis = 'codmotvis';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String images = 'images';
  static const String firm = 'firm';
  static const String observation = 'observation';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class News {
  int? id;
  String status;
  int userId;
  int? workId;
  int? summaryId;
  String nommotvis;
  String codmotvis;
  String latitude;
  String longitude;
  dynamic images;
  dynamic firm;
  String observation;

  News({
    this.id,
    required this.status,
    required this.userId,
    required this.workId,
    required this.summaryId,
    required this.nommotvis,
    required this.codmotvis,
    required this.latitude,
    required this.longitude,
    this.images,
    this.firm,
    required this.observation,
  });

  factory News.fromJson(Map<String, dynamic> json) => News(
    id: json["id"],
    status: json["status"],
    userId: json["user_id"],
    workId: json["work_id"],
    summaryId: json["summary_id"],
    nommotvis: json["nommotvis"],
    codmotvis: json["codmotvis"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    images: json["images"],
    firm: json["firm"],
    observation: json["observation"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "user_id": userId,
    "work_id": workId,
    "summary_id": summaryId,
    "nommotvis": nommotvis,
    "codmotvis": codmotvis,
    "latitude": latitude,
    "longitude": longitude,
    "images": images,
    "firm": firm,
    "observation": observation,
  };
}
