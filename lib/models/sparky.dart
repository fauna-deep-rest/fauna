import 'package:flutter/foundation.dart';

class Sparky with ChangeNotifier {
  final String id;
  List<String> summary;

  Sparky({
    required this.id,
    this.summary = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'summary': summary,
    };
  }

  factory Sparky.fromMap(Map<String, dynamic> map) {
    return Sparky(
      id: map['id'] ?? '',
      summary: List<String>.from(map['summary'] ?? []),
    );
  }

  void addSummary(String newSummary) {
    summary.add(newSummary);
    notifyListeners();
  }

  void clearSummary() {
    summary.clear();
    notifyListeners();
  }
}
