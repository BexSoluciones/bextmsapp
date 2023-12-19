import 'dart:convert';

const String tableUsers = 'users';

User userFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromJson(jsonData);
}

String userToJson(User data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

List<User> allUsersFromJson(String str) {
  final jsonData = json.decode(str);
  return List<User>.from(jsonData.map((x) => User.fromJson(x)));
}

String allUsersToJson(List<User> data) {
  final dyn = List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}

class UserFields {
  static final List<String> values = [
    id,
    name,
    email,
    createdAt,
    updatedAt,
    profilePhotoUrl
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String email = 'email';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String profilePhotoUrl = 'profilePhotoUrl';
}

class User {
  int? id;
  String? name;
  String? email;
  String? createdAt;
  String? updatedAt;
  String? profilePhotoUrl;

  // ignore: sort_constructors_first
  User({
    this.id,
    this.name,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.profilePhotoUrl,
  });

  User copy({
    int? id,
    String? name,
    String? email,
    String? createdAt,
    String? updatedAt,
    String? profilePhotoUrl,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      );

  // ignore: sort_constructors_first
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
    profilePhotoUrl: json['profile_photo_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'profile_photo_url': profilePhotoUrl,
  };
}
