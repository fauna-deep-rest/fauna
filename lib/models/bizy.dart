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

class Step {
  final int step;
  final String task;

  Step({required this.step, required this.task});

  factory Step.fromMap(Map<String, dynamic> map) {
    return Step(
      step: map['step'] ?? 0,
      task: map['task'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Step $step: $task';
  }
}

class BizyResponse {
  final String answer;
  final String action;
  final List<Step> steps;

  BizyResponse({
    required this.answer,
    required this.action,
    this.steps = const [],
  });

  factory BizyResponse.fromMap(Map<String, dynamic> map) {
    var stepsList =
        (map['steps'] as List?)?.map((item) => Step.fromMap(item)).toList() ??
            [];

    return BizyResponse(
      answer: map['answer'] ?? '',
      action: map['action'] ?? '',
      steps: stepsList,
    );
  }
}
