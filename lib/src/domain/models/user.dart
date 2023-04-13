import 'package:equatable/equatable.dart';

class User extends Equatable {

  final int? id;
  final String? email;
  final String? name;
  final String? username;

  const User({
    this.id,
    required this.email,
    required this.name,
    this.username
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id : map['id'] != null ? map['id'] as int : null,
      email : map['email'] != null ? map['email'] as String : null,
      name : map['name'] != null ? map['name'] as String : null,
      username : map['username'] != null ? map['username'] as String : null,
    );
  }

  Map toMap(){
    return  {
      'id': id,
      'email': email,
      'name': name,
      'username': username
    };
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [id, email, name, username];
}
