/// BrunoViewModel manages the business logic and state for Bruno-related features
/// Handles communication between the UI layer and data repository
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/bruno.dart';
import '../repositories/bruno_repo.dart';

class BrunoViewModel with ChangeNotifier {
  /// Current Bruno instance being managed
  Bruno? bruno;

  /// Repository instance for Bruno-related database operations
  final BrunoRepository _repository = BrunoRepository();

  /// Latest output from Bruno AI
  String brunoOutput = '';
  String brunoAction = '';

  /// List of conversation messages between user and Bruno
  List<Map<String, String>> _dialogues = [];

  /// Creates a new Bruno instance in the database
  /// @param brunoId - Unique identifier for Bruno
  /// @return Future<void>
  Future<void> createBruno(String brunoId) async {
    await _repository.createBruno(brunoId);
  }

  /// Loads an existing Bruno instance from the database
  /// @param brunoId - Unique identifier for Bruno
  /// @return Future<Bruno?> - Returns Bruno object if found
  Future<Bruno?> loadBruno(String brunoId) async {
    bruno = await _repository.fetchBruno(brunoId);
    return bruno;
  }

  /// Adds a new summary to the current Bruno instance
  /// @param newSummary - Summary text to add
  /// @return Future<void>
  Future<void> addSummary(String newSummary) async {
    if (bruno != null) {
      bruno!.addSummary(newSummary);
      await _repository.addSummary(bruno!.id, newSummary);
      notifyListeners();
    }
  }

  /// Loads initial data for Bruno and processes it through AI
  /// @param brunoId - Unique identifier for Bruno
  /// @return Future<void>
  Future<void> loadData(String brunoId) async {
    try {
      bruno = await _repository.fetchBruno(brunoId);
    } catch (e) {
      print('load bruno failed');
    }
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('bruno_completion')
          .call({"dialogues": _dialogues, "bruno_id": brunoId});

      brunoOutput = response.data['answer'];
      brunoAction = response.data['action'];
      _dialogues.add({'role': 'assistant', 'content': brunoOutput});
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      notifyListeners();
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
    _dialogues.add({'role': 'user', 'content': prompt});

    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('bruno_completion')
          .call({"dialogues": _dialogues, "bruno_id": id});
      brunoOutput = response.data['answer'];
      brunoAction = response.data['action'];
      _dialogues
          .add({'role': 'assistant', 'content': response.data.toString()});
      notifyListeners();
    } catch (e) {
      print('Error handling submission: $e');
    }
  }
}
