import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  final String id;
  String name;
  String sparkyId;
  String? brunoId; // 可選的屬性
  String? bizyId; // 可選的屬性

  User({
    required this.id,
    required this.name,
    required this.sparkyId,
    this.brunoId,
    this.bizyId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sparkyId': sparkyId,
      'brunoId': brunoId,
      'bizyId': bizyId,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] ?? '',
      sparkyId: map['sparkyId'] ?? '',
      brunoId: map['brunoId'] ?? '',
      bizyId: map['bizyId'] ?? '',
    );
  }
}
