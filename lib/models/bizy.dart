import 'package:flutter/foundation.dart';

class Bizy with ChangeNotifier {
  final String id;
  List<String> summary;
  List<Map<String, dynamic>> todoList;
  String procrastinationType;

  Bizy({
    required this.id,
    this.summary = const [],
    this.todoList = const [],
    this.procrastinationType = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'summary': summary,
      'todo_list': todoList,
      'procrastination_type': procrastinationType,
    };
  }

  factory Bizy.fromMap(Map<String, dynamic> map) {
    return Bizy(
      id: map['id'] ?? '',
      summary: List<String>.from(map['summary'] ?? []),
      todoList: List<Map<String, dynamic>>.from(map['todo_list'] ?? []),
      procrastinationType: map['procrastination_type'] ?? '',
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

  void updateTodoList(List<Map<String, dynamic>> newTodoList) {
    todoList = newTodoList;
    notifyListeners();
  }

  void setProcrastinationType(String type) {
    procrastinationType = type;
    notifyListeners();
  }
}
