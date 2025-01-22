import 'package:fauna/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../repositories/bizy_repo.dart';
import '../models/bizy.dart';

class BizyViewModel with ChangeNotifier {
  Bizy? bizy;
  final BizyRepository _repository = BizyRepository();
  //Todo: dialogues message class
  List<DialogueMessage> _dialogues = [];
  String bizyType = 'bizy_main';

  String bizyOutput = '';
  String smallBizyOutput = '';
  bool showSmallBizy = false;

  Future<void> createBizy(String bizyId) async {
    await _repository.createBizy(bizyId);
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

  // Initialize function to get bizy info
  Future<void> loadData(String id) async {
    try {
      bizy = await _repository.fetchBizy("bizy_$id");
    } catch (e) {
      print("load bizy failed");
    }
    try {
      var response = await getResponse(_dialogues, id, bizyType);
      bizyOutput = response.answer;
      _dialogues.add(DialogueMessage(role: 'assistant', content: bizyOutput));
    } catch (e) {
      print('Error loading prompt: $e');
    } finally {
      print("load data for bizy success.");
      notifyListeners();
    }
  }

  /// Update BizyType based on action from response. show small speech bubble when switch to small bees.
  void updateBizyType(String action) {
    switch (action) {
      case 'analysis':
        bizyType = 'bizy_analysis';
        break;
      case 'break_task':
        bizyType = 'bizy_task';
        break;
      case 'excuse':
        bizyType = 'bizy_excuse';
        break;
      case 'finish_analysis':
        bizyType = 'bizy_main';
        break;
      case 'set_next_action':
        bizyType = 'bizy_main';
        break;
      case 'change_excuse':
        bizyType = 'bizy_main';
        break;
      default:
        print("No action matched. Current bizyType remains: $bizyType");
        break;
    }
  }

  /// Handle actions that main Bizy call small bees.
  Future<void> callBees(String action, String id) async {
    if (action == 'analysis') {
      updateBizyType(action);
      showSmallBizy = true;
      await updateOutput(id);
    } else if (action == 'break_task') {
      updateBizyType(action);
      showSmallBizy = true;

      var taskResponse = await updateOutput(id);
      if (taskResponse.action == "break_down_tasks") {
        for (var step in taskResponse.steps) {
          _dialogues.add(
              DialogueMessage(role: 'assistant', content: step.toString()));
        }
      }
    } else if (action == 'change_excuse') {
      updateBizyType(action);
      showSmallBizy = true;
      await updateOutput(id);
    } else {
      return;
    }
  }

  /// Update output based on bizyType
  Future<BizyResponse> updateOutput(String id) async {
    BizyResponse response = await getResponse(_dialogues, id, bizyType);

    if (bizyType == 'bizy_main') {
      bizyOutput = response.action + response.answer;
      _dialogues.add(DialogueMessage(role: 'assistant', content: bizyOutput));
    } else {
      smallBizyOutput = response.action + response.answer;
      _dialogues
          .add(DialogueMessage(role: 'assistant', content: smallBizyOutput));
    }

    return response;
  }

  /// Logic for Bizy to handle user's input
  Future<void> handleSubmit(
      String prompt, String id, BuildContext context) async {
    if (prompt.trim().isEmpty) return;
    _dialogues.add(DialogueMessage(role: 'user', content: prompt));
    try {
      if (bizyType == "bizy_main") {
        showSmallBizy = false;

        BizyResponse response = await updateOutput(id);
        await callBees(response.action, id);
        if (response.action == 'summary') {
          // todo: save after conversation
        }
      } else if (bizyType == "bizy_analysis") {
        bizyOutput = "Anaysising";
        BizyResponse response = await updateOutput(id);

        if (response.action == "finish_analysis") {
          updateBizyType(response.action); //change back to bizy_main
          response = await updateOutput(id);

          callBees(response.action, id); //bizy might call another bees
          print('finish_analysis');
        }
      } else if (bizyType == "bizy_task") {
        bizyOutput = "Breaking task!";
        BizyResponse response = await updateOutput(id);

        if (response.action == "break_down_tasks") {
          for (var step in response.steps) {
            print(step);
            _dialogues.add(
                DialogueMessage(role: 'assistant', content: smallBizyOutput));
          }
        } else if (response.action == "set_next_action") {
          updateBizyType(response.action);
          print("finish breaking task");
        }
      } else if (bizyType == "bizy_excuse") {
        BizyResponse response = await updateOutput(id);

        if (response.action == "change_excuse") {
          updateBizyType(response.action);
        }
      }
    } catch (e) {
      print('Error handling submission: $e');
    }
  }
}

Future<BizyResponse> getResponse(
    List<DialogueMessage> dialogues, String id, String bizyType) async {
  final dialogueMaps = dialogues.map((d) => d.toMap()).toList();
  var response = await FirebaseFunctions.instance
      .httpsCallable('${bizyType}_completion')
      .call({
    "dialogues": dialogueMaps,
    "user_id": id,
    "bizy_type": bizyType,
  });
  return BizyResponse.fromMap(response.data);
}
