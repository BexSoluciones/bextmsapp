import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

//datasources
import '../../data/datasources/local/hive/core/hive_types.dart';
import '../../data/datasources/local/hive/core/model/hive_model.dart';

part 'user.g.dart';

@HiveType(typeId: HiveTypes.userModelId)
class User with EquatableMixin, HiveModelMixin {
  static const String userKey = 'user';

  @override
  // Model unique key
  String get key => userKey;

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? email;
  @HiveField(2)
  final String? name;
  @HiveField(3)
  final String? username;

  const User({this.id, required this.email, required this.name, this.username});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as int : null,
      email: map['email'] != null ? map['email'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      username: map['username'] != null ? map['username'] as String : null,
    );
  }

  Map toMap() {
    return {'id': id, 'email': email, 'name': name, 'username': username};
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [id, email, name, username];
}

extension UserExtension on User {
  bool get isEmpty => email == null || name == null || username == null;
}
