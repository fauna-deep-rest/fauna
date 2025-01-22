import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../repositories/bizy_repo.dart';
import '../models/bizy.dart';
import '../models/dialogue.dart';

class BizyState {
  final Bizy? bizy;
  final bool isLoading;
  final String currentBizyType;
  final String mainOutput;
  final String smallOutput;
  final String beesName;
  final bool showSmallBizy;
  final String? error;
  final List<DialogueMessage> dialogues;
  final bool isSummaryAction;

  const BizyState({
    this.bizy,
    this.isLoading = false,
    this.currentBizyType = 'bizy_main',
    this.mainOutput = '',
    this.smallOutput = '',
    this.beesName = 'Bizy',
    this.showSmallBizy = false,
    this.error,
    this.dialogues = const [],
    this.isSummaryAction = false,
  });

  BizyState copyWith({
    Bizy? bizy,
    bool? isLoading,
    String? currentBizyType,
    String? mainOutput,
    String? smallOutput,
    String? beesName,
    bool? showSmallBizy,
    String? error,
    List<DialogueMessage>? dialogues,
    bool? isSummaryAction,
  }) {
    return BizyState(
      bizy: bizy ?? this.bizy,
      isLoading: isLoading ?? this.isLoading,
      currentBizyType: currentBizyType ?? this.currentBizyType,
      mainOutput: mainOutput ?? this.mainOutput,
      smallOutput: smallOutput ?? this.smallOutput,
      showSmallBizy: showSmallBizy ?? this.showSmallBizy,
      error: error,
      dialogues: dialogues ?? this.dialogues,
      isSummaryAction: isSummaryAction ?? this.isSummaryAction,
    );
  }
}

/// BizyViewModel manages the business logic and state for Bizy-related features
/// Handles communication between the UI layer and data repository

class BizyViewModel with ChangeNotifier {
  final BizyRepository _repository = BizyRepository();
  BizyState _state = const BizyState();

  BizyState get state => _state;

  void _setState(BizyState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Creates a new Bizy instance in the database
  /// @param bizyId - Unique identifier for Bizy
  /// @return Future<void>
  Future<void> createBizy(String bizyId) async {
    try {
      _setState(_state.copyWith(isLoading: true));
      await _repository.createBizy(bizyId);
      _setState(_state.copyWith(isLoading: false));
    } catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        error: 'Failed to create Bizy: $e',
      ));
    }
  }

  /// Adds a new summary to the current Bizy instance
  /// @param newSummary - Summary text to add
  /// @return Future<void>
  Future<void> addSummary(String newSummary) async {
    if (_state.bizy != null) {
      try {
        _setState(_state.copyWith(isLoading: true));
        _state.bizy!.addSummary(newSummary);
        await _repository.addSummary(_state.bizy!.id, newSummary);
        _setState(_state.copyWith(isLoading: false));
      } catch (e) {
        _setState(_state.copyWith(
          isLoading: false,
          error: 'Failed to add summary: $e',
        ));
      }
    }
  }

  Future<void> updateTodoList(List<Map<String, dynamic>> newTodoList) async {
    if (_state.bizy != null) {
      try {
        _setState(_state.copyWith(isLoading: true));
        _state.bizy!.updateTodoList(newTodoList);
        await _repository.updateTodoList(_state.bizy!.id, newTodoList);
        _setState(_state.copyWith(isLoading: false));
      } catch (e) {
        _setState(_state.copyWith(
          isLoading: false,
          error: 'Failed to update todo list: $e',
        ));
      }
    }
  }

  /// Loads initial data for Bizy and processes it through AI
  /// @param bizyId - Unique identifier for Bizy
  /// @return Future<void>
  Future<void> loadData(String id) async {
    try {
      _setState(_state.copyWith(isLoading: true));

      final bizy = await _repository.fetchBizy("bizy_$id");
      var response =
          await getResponse(_state.dialogues, id, _state.currentBizyType);

      final dialogues = [..._state.dialogues];
      dialogues
          .add(DialogueMessage(role: 'assistant', content: response.answer));

      _setState(_state.copyWith(
        isLoading: false,
        bizy: bizy,
        mainOutput: response.answer,
        dialogues: dialogues,
      ));
    } catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        error: 'Failed to load data: $e',
      ));
    }
  }

  /// Updates the current Bizy type based on the specified action
  /// @param action - The action that determines the new Bizy type
  void updateBizyType(String action) {
    String newBizyType;
    String bee;
    switch (action) {
      case 'analysis':
        newBizyType = 'bizy_analysis';
        bee = 'Planbee';
        _setState(_state.copyWith(currentBizyType: newBizyType, beesName: bee));
        break;
      case 'break_task':
        newBizyType = 'bizy_task';
        bee = 'Taskbee';
        _setState(_state.copyWith(currentBizyType: newBizyType, beesName: bee));
        break;
      case 'excuse':
        newBizyType = 'bizy_excuse';
        bee = 'Excubee';
        _setState(_state.copyWith(currentBizyType: newBizyType, beesName: bee));
        break;
      case 'finish_analysis':
      case 'set_next_action':
      case 'change_excuse':
        newBizyType = 'bizy_main';
        _setState(_state.copyWith(currentBizyType: newBizyType));
        break;
      default:
        return;
    }
  }

  /// Calls the Bees service based on the specified action
  /// @param action - The action to be performed
  /// @param id - Unique identifier for Bizy
  /// @return Future<void>
  Future<void> callBees(String action, String id) async {
    try {
      if (action == 'analysis') {
        updateBizyType(action);
        _setState(_state.copyWith(showSmallBizy: true));
        await updateOutput(id);
      }
      if (action == 'break_task') {
        updateBizyType(action);
        _setState(_state.copyWith(showSmallBizy: true));

        var taskResponse = await updateOutput(id);
        if (taskResponse.action == "break_down_tasks") {
          final dialogues = [..._state.dialogues];
          String stepsOutput = '${taskResponse.answer}\n';
          for (var step in taskResponse.steps) {
            dialogues.add(
                DialogueMessage(role: 'assistant', content: step.toString()));
            stepsOutput += '$step\n';
          }
          _setState(_state.copyWith(
            dialogues: dialogues,
            smallOutput: stepsOutput,
          ));
        }
      }
      if (action == 'excuse') {
        updateBizyType(action);
        _setState(_state.copyWith(showSmallBizy: true));
        await updateOutput(id);
      }
      if (action == 'summary') {
        _setState(_state.copyWith(isSummaryAction: true));
      }
    } catch (e) {
      _setState(_state.copyWith(
        error: 'Failed to process action: $e',
      ));
    }
  }

  /// Updates the output based on the current state and AI response
  /// @param id - Unique identifier for Bizy
  /// @return Future<BizyResponse> - Returns the response from the AI
  Future<BizyResponse> updateOutput(String id) async {
    try {
      BizyResponse response = await getResponse(
        _state.dialogues,
        id,
        _state.currentBizyType,
      );

      final dialogues = [..._state.dialogues];
      if (_state.currentBizyType == 'bizy_main') {
        final output = response.action + response.answer;
        dialogues.add(DialogueMessage(role: 'assistant', content: output));
        _setState(_state.copyWith(
          mainOutput: output,
          dialogues: dialogues,
        ));
      } else {
        final output = response.action + response.answer;
        dialogues.add(DialogueMessage(role: 'assistant', content: output));
        _setState(_state.copyWith(
          smallOutput: output,
          dialogues: dialogues,
        ));
      }

      return response;
    } catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        error: 'Failed to update output: $e',
      ));
      rethrow;
    }
  }

  /// Handles user input submission and processes it through AI
  /// @param id - User identifier
  /// @param prompt - User input text
  /// @param context - BuildContext for UI updates
  /// @return Future<void>
  Future<void> handleSubmit(
      String prompt, String id, BuildContext context) async {
    if (prompt.trim().isEmpty) return;

    try {
      _setState(_state.copyWith(isLoading: true));

      final dialogues = [..._state.dialogues];
      dialogues.add(DialogueMessage(role: 'user', content: prompt));
      _setState(_state.copyWith(dialogues: dialogues));

      if (_state.currentBizyType == "bizy_main") {
        _setState(_state.copyWith(showSmallBizy: false));
        BizyResponse response = await updateOutput(id);
        await callBees(response.action, id);
      } else if (_state.currentBizyType == "bizy_analysis") {
        _setState(_state.copyWith(mainOutput: "Analysing"));
        BizyResponse response = await updateOutput(id);

        if (response.action == "finish_analysis") {
          updateBizyType(response.action);
          // response = await updateOutput(id);
          // await Future.delayed(Duration(seconds: 3));
          // await callBees(response.action, id);
        }
      } else if (_state.currentBizyType == "bizy_task") {
        _setState(_state.copyWith(mainOutput: "Breaking task!"));
        BizyResponse response = await updateOutput(id);

        if (response.action == "break_down_tasks") {
          final newDialogues = [..._state.dialogues];
          String stepsOutput = '${response.answer}\n';
          for (var step in response.steps) {
            newDialogues.add(DialogueMessage(
              role: 'assistant',
              content: step.toString(),
            ));
            stepsOutput += '$step\n';
          }
          _setState(_state.copyWith(
            dialogues: newDialogues,
            smallOutput: stepsOutput,
          ));
        } else if (response.action == "set_next_action") {
          updateBizyType(response.action);
        }
      } else if (_state.currentBizyType == "bizy_excuse") {
        BizyResponse response = await updateOutput(id);
        if (response.action == "change_excuse") {
          updateBizyType(response.action);
        }
      }

      _setState(_state.copyWith(isLoading: false));
    } catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        error: 'Failed to handle submission: $e',
      ));
    }
  }
}

/// Gets the response from the AI based on the dialogues and Bizy type
/// @param dialogues - List of dialogue messages
/// @param id - Unique identifier for user
/// @param bizyType - Current type of Bizy
/// @return Future<BizyResponse> - Returns the response from the AI
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
