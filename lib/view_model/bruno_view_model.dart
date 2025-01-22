/// BrunoViewModel manages the business logic and state for Bruno-related features
/// Handles communication between the UI layer and data repository
library;

import 'package:fauna/models/dialogue.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/bruno.dart';
import '../repositories/bruno_repo.dart';

class BrunoState {
  final Bruno? bruno;
  final bool isLoading;
  final String brunoOutput;
  final List<DialogueMessage> dialogues; // 修改为 DialogueMessage 类型
  final String brunoAction;

  const BrunoState({
    this.bruno,
    this.isLoading = false,
    this.brunoOutput = '',
    this.dialogues = const [],
    this.brunoAction = '',
  });

  BrunoState copyWith({
    Bruno? bruno,
    bool? isLoading,
    String? brunoOutput,
    List<DialogueMessage>? dialogues,
    String? brunoAction,
  }) {
    return BrunoState(
      bruno: bruno ?? this.bruno,
      isLoading: isLoading ?? this.isLoading,
      brunoOutput: brunoOutput ?? this.brunoOutput,
      dialogues: dialogues ?? this.dialogues,
      brunoAction: brunoAction ?? this.brunoAction,
    );
  }
}

class BrunoViewModel with ChangeNotifier {
  /// Repository instance for Bruno-related database operations
  final BrunoRepository _repository = BrunoRepository();

  BrunoState _state = const BrunoState();
  BrunoState get state => _state;

  void _setState(BrunoState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Creates a new Bruno instance in the database
  /// @param brunoId - Unique identifier for Bruno
  /// @return Future<void>
  Future<void> createBruno(String brunoId) async {
    await _repository.createBruno(brunoId);
  }

  /// Loads an existing Bruno instance from the database
  /// @param brunoId - Unique identifier for Bruno
  /// @return Future<Bruno?> - Returns Bruno object if found
  Future<void> loadBruno(String brunoId) async {
    final bruno = await _repository.fetchBruno(brunoId);
    _setState(state.copyWith(bruno: bruno));
  }

  /// Adds a new summary to the current Bruno instance
  /// @param newSummary - Summary text to add
  /// @return Future<void>
  Future<void> addSummary(String newSummary) async {
    if (_state.bruno != null) {
      _state.bruno!.addSummary(newSummary);
      await _repository.addSummary(_state.bruno!.id, newSummary);
      _setState(state.copyWith(bruno: _state.bruno));
    }
  }

  /// Loads initial data for Bruno and processes it through AI
  /// @param brunoId - Unique identifier for Bruno
  /// @return Future<void>
  Future<void> loadData(String brunoId) async {
    try {
      _setState(state.copyWith(isLoading: true));
      final bruno = await _repository.fetchBruno(brunoId);
      BrunoResponse response = await getResponse(_state.dialogues, brunoId);
      final dialogues = [..._state.dialogues];
      dialogues.add(DialogueMessage(role: 'user', content: response.answer));

      _setState(state.copyWith(
        bruno: bruno,
        brunoOutput: response.answer,
        brunoAction: response.action,
        dialogues: dialogues,
        isLoading: false,
      ));
    } catch (e) {
      print('Error loading data: $e');
      _setState(state.copyWith(isLoading: false));
    }
  }

  /// Handles user input submission and processes it through AI
  /// @param id - Bruno identifier
  /// @param prompt - User input text
  /// @param context - BuildContext for UI updates
  /// @return Future<void>
  Future<void> handleSubmit(
      String id, String prompt, BuildContext context) async {
    if (prompt.trim().isEmpty) return;
    final dialogues = [..._state.dialogues];
    dialogues.add(DialogueMessage(role: 'user', content: prompt));
    _setState(state.copyWith(dialogues: dialogues));

    try {
      BrunoResponse response = await updateOutput(id);
    } catch (e) {
      print('Error handling submission: $e');
    }
  }

  /// Gets the response from the AI based on the dialogues
  /// @param dialogues - List of dialogue messages
  /// @param id - Unique identifier for bruno
  /// @return Future<BrunoResponse> - Returns the response from the AI
  Future<BrunoResponse> getResponse(
      List<DialogueMessage> dialogues, String id) async {
    final dialogueMaps = dialogues.map((d) => d.toMap()).toList();
    var response = await FirebaseFunctions.instance
        .httpsCallable('bruno_completion')
        .call({
      "dialogues": dialogueMaps,
      "bruno_id": id,
    });
    return BrunoResponse.fromMap(response.data);
  }

  /// Updates the output based on the current state and AI response
  /// @param id - Unique identifier for Bruno
  /// @return Future<BrunoResponse> - Returns the response from the AI
  Future<BrunoResponse> updateOutput(String id) async {
    try {
      BrunoResponse response = await getResponse(_state.dialogues, id);

      final dialogues = [..._state.dialogues];
      dialogues
          .add(DialogueMessage(role: 'assistant', content: response.answer));
      _setState(state.copyWith(
        brunoOutput: response.answer,
        brunoAction: response.action,
        dialogues: [
          ...dialogues,
          DialogueMessage(role: 'assistant', content: response.answer)
        ],
      ));
      return response;
    } catch (e) {
      print('Failed to update output: $e');
      rethrow;
    }
  }
}
