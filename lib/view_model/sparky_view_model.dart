import 'package:fauna/models/dialogue.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../repositories/sparky_repo.dart';
import '../models/sparky.dart';

class SparkyState {
  final Sparky? sparky;
  final bool isLoading;
  final String sparkyOutput;
  final List<DialogueMessage> dialogues;
  final bool showBizyButton;
  final bool showBrunoButton;

  const SparkyState({
    this.sparky,
    this.isLoading = false,
    this.sparkyOutput = '',
    this.dialogues = const [],
    this.showBizyButton = false,
    this.showBrunoButton = false,
  });

  SparkyState copyWith({
    Sparky? sparky,
    bool? isLoading,
    String? sparkyOutput,
    List<DialogueMessage>? dialogues,
    bool? showBizyButton,
    bool? showBrunoButton,
  }) {
    return SparkyState(
      sparky: sparky ?? this.sparky,
      isLoading: isLoading ?? this.isLoading,
      sparkyOutput: sparkyOutput ?? this.sparkyOutput,
      dialogues: dialogues ?? this.dialogues,
      showBizyButton: showBizyButton ?? this.showBizyButton,
      showBrunoButton: showBrunoButton ?? this.showBrunoButton,
    );
  }
}

class SparkyViewModel with ChangeNotifier {
  SparkyState _state = const SparkyState();
  final SparkyRepository _repository = SparkyRepository();

  SparkyState get state => _state;

  void _setState(SparkyState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> createSparky(String sparkyId) async {
    await _repository.createSparky(sparkyId);
  }

  Future<void> loadSparky(String sparkyId) async {
    final sparky = await _repository.fetchSparky(sparkyId);
    _setState(_state.copyWith(sparky: sparky));
  }

  Future<void> addSummary(String newSummary) async {
    if (_state.sparky != null) {
      _state.sparky!.addSummary(newSummary);
      await _repository.addSummary(_state.sparky!.id, newSummary);
      _setState(_state.copyWith(sparky: _state.sparky));
    }
  }

  Future<void> loadData(String sparkyId) async {
    try {
      _setState(_state.copyWith(isLoading: true));
      final sparky = await _repository.fetchSparky(sparkyId);
      SparkyResponse response = await getResponse(_state.dialogues, sparkyId);
      final dialogues = [..._state.dialogues];
      dialogues
          .add(DialogueMessage(role: 'assistant', content: response.answer));

      _setState(_state.copyWith(
          sparky: sparky,
          sparkyOutput: response.answer,
          dialogues: dialogues,
          isLoading: false));
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<SparkyResponse> updateOutput(String id) async {
    try {
      SparkyResponse response = await getResponse(_state.dialogues, id);

      final dialogues = [..._state.dialogues];
      dialogues
          .add(DialogueMessage(role: 'assistant', content: response.answer));
      _setState(_state.copyWith(
        sparkyOutput: response.answer,
        dialogues: dialogues,
      ));
      return response;
    } catch (e) {
      print('Failed to update output: $e');
      rethrow;
    }
  }

  Future<void> handleSubmit(
      String id, String prompt, BuildContext context) async {
    if (prompt.trim().isEmpty) return;
    final dialogues = [..._state.dialogues];
    dialogues.add(DialogueMessage(role: 'user', content: prompt));
    _setState(_state.copyWith(dialogues: dialogues));

    try {
      SparkyResponse response = await updateOutput(id);

      if (response.action == 'guide_to_bruno') {
        _setState(_state.copyWith(showBrunoButton: true));
      } else if (response.action == 'guide_to_bizy') {
        _setState(_state.copyWith(showBizyButton: true));
      }
    } catch (e) {
      print('Error handling submission: $e');
    }
  }

  Future<SparkyResponse> getResponse(
      List<DialogueMessage> dialogues, String id) async {
    final dialogueMaps = dialogues.map((d) => d.toMap()).toList();
    var response = await FirebaseFunctions.instance
        .httpsCallable('sparky_completion')
        .call({
      "dialogues": dialogueMaps,
      "sparky_id": id,
    });
    return SparkyResponse.fromMap(response.data);
  }
}
