import 'package:fauna/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../repositories/bizy_repo.dart';
import '../models/bizy.dart';

class BizyViewModel with ChangeNotifier {
  Bizy? bizy;
  final BizyRepository _repository = BizyRepository();

  List<Map<String, String>> _dialogues = [];
  String bizyType = 'bizy_main';

  String bizyOutput = '';
  String smallBizyOutput = '';
  bool showSmallBizy = false;

  Future<void> createBizy(String bizyId) async {
    await _repository.createBizy(bizyId);
  }

  Future<Bizy?> loadBizy(String bizyId) async {
    bizy = await _repository.fetchBizy(bizyId);
    return bizy;
  }

  Future<void> addSummary(String newSummary) async {
    if (bizy != null) {
      bizy!.addSummary(newSummary);
      await _repository.addSummary(bizy!.id, newSummary);
      notifyListeners();
    }
  }

  Future<void> updateTodoList(List<Map<String, dynamic>> newTodoList) async {
    if (bizy != null) {
      bizy!.updateTodoList(newTodoList);
      await _repository.updateTodoList(bizy!.id, newTodoList);
      notifyListeners();
    }
  }

  Future<void> setProcrastinationType(String type) async {
    if (bizy != null) {
      bizy!.setProcrastinationType(type);
      await _repository.setProcrastinationType(bizy!.id, type);
      notifyListeners();
    }
  }

  Future<void> loadData(String id) async {
    try {
      bizy = await _repository.fetchBizy("bizy_$id");
    } catch (e) {
      print("load bizy failed");
    }
    try {
      var response = await getResponse(_dialogues, id, bizyType);

      bizyOutput = response.answer;
      _dialogues.add({'role': 'assistant', 'content': bizyOutput});
    } catch (e) {
      print('Error loading prompt: $e');
    } finally {
      print("load data for bizy success.");
      notifyListeners();
    }
  }

  // todo: update type

  Future<void> handleSubmit(
      String prompt, String id, BuildContext context) async {
    if (prompt.trim().isEmpty) return;
    _dialogues.add({'role': 'user', 'content': prompt});

    try {
      if (bizyType == "bizy_main") {
        var response = await getResponse(_dialogues, id, bizyType);
        bizyOutput = response.action + response.answer;
        showSmallBizy = false;
        _dialogues.add({'role': 'assistant', 'content': bizyOutput});

        if (response.action == 'analysis') {
          bizyType = 'bizy_analysis';
          var analysisResponse = await getResponse(_dialogues, id, bizyType);
          smallBizyOutput = analysisResponse.answer;

          showSmallBizy = true;
          _dialogues.add({'role': 'assistant', 'content': smallBizyOutput});
        }
        if (response.action == 'break_task') {
          bizyType = 'bizy_task';
          showSmallBizy = true;

          var taskyResponse = await getResponse(_dialogues, id, bizyType);
          smallBizyOutput = taskyResponse.answer;
          _dialogues.add({'role': 'assistant', 'content': smallBizyOutput});
        }
        if (response.action == 'change_excuse') {
          print("change_excuse");
        }
        if (response.action == 'summary') {
          // todo: save after conversation
        }
      } else if (bizyType == "bizy_analysis") {
        var analysisResponse = await getResponse(_dialogues, id, bizyType);
        smallBizyOutput =
            analysisResponse.answer + " " + analysisResponse.action;
        _dialogues.add({'role': 'assistant', 'content': smallBizyOutput});
        bizyOutput = "Anaysising";

        if (analysisResponse.action == "finish_analysis") {
          bizyType = 'bizy_main';
          var response = await getResponse(_dialogues, id, bizyType);
          bizyOutput = response.action + response.answer;
          _dialogues.add({'role': 'assistant', 'content': bizyOutput});
          if (response.answer == "break_task") {
          } else if (response.answer == "change_excuse") {}
          print('finish_analysis');
        }
      } else if (bizyType == "bizy_task") {
        var taskyResponse = await getResponse(_dialogues, id, bizyType);
        smallBizyOutput = taskyResponse.action + "\n" + taskyResponse.answer;
        _dialogues.add({'role': 'assistant', 'content': smallBizyOutput});
        bizyOutput = "Breaking task!";
        if (taskyResponse.action == "break_down_tasks") {
          for (var step in taskyResponse.steps) {
            print(step);
            _dialogues.add({'role': 'assistant', 'content': step.toString()});
          }
        } else if (taskyResponse.action == "set_next_action") {
          bizyType = 'bizy_main';
          print("finish breaking task");
        }
      } else if (bizyType == "change_excuse") {}
    } catch (e) {
      print('Error handling submission: $e');
    }
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

Future<BizyResponse> getResponse(
    Object dialogues, String id, String bizyType) async {
  var response = await FirebaseFunctions.instance
      .httpsCallable('${bizyType}_completion')
      .call({
    "dialogues": dialogues,
    "user_id": id,
    "bizy_type": bizyType,
  });
  return BizyResponse.fromMap(response.data);
}
