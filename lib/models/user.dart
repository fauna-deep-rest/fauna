import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  String? id;
  String name = '';
  String summary = '';

  User({
    required this.id,
    required this.name,
    required this.summary,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'summary': summary,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String? id) {
    return User(
      id: id,
      name: map['name'],
      summary: map['summary'],
    );
  }
}
