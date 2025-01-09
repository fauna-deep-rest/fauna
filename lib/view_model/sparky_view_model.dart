import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:provider/provider.dart';
import '../repositories/sparky_repo.dart';
import '../models/sparky.dart';

class SparkyViewModel with ChangeNotifier {
  Sparky? sparky;
  final SparkyRepository _repository = SparkyRepository();
  //List<Map<String, String>> get dialogues => List.unmodifiable(_dialogues);
  String sparkyOutput = '';
  List<Map<String, String>> _dialogues = [];
  bool showBizyButton = false;

  Future<void> createSparky(String sparkyId) async {
    await _repository.createSparky(sparkyId);
  }

  Future<Sparky?> loadSparky(String sparkyId) async {
    sparky = await _repository.fetchSparky(sparkyId);
    return sparky;
  }

  Future<void> addSummary(String newSummary) async {
    if (sparky != null) {
      sparky!.addSummary(newSummary);
      await _repository.addSummary(sparky!.id, newSummary);
      notifyListeners();
    }
  }

  Future<void> loadData(String sparkyId) async {
    try {
      sparky = await _repository.fetchSparky(sparkyId);
    } catch (e) {
      print("load sparky failed");
    }
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('sparky_completion')
          .call({"dialogues": _dialogues, "sparky_id": sparkyId});

      sparkyOutput = response.data.toString();
      _dialogues.add({'role': 'assistant', 'content': sparkyOutput});
    } catch (e) {
      print('Error loading prompt: $e');
    } finally {
      print("load data for sparky success.");
      notifyListeners();
    }
  }

  Future<void> handleSubmit(
      String id, String prompt, BuildContext context) async {
    if (prompt.trim().isEmpty) return;
    _dialogues.add({'role': 'user', 'content': prompt});

    try {
      print("start getting response!");
      final response = await FirebaseFunctions.instance
          .httpsCallable('sparky_completion')
          .call({"dialogues": _dialogues, "sparky_id": id});

      sparkyOutput = response.data.toString();
      _dialogues.add({'role': 'assistant', 'content': sparkyOutput});
      //notifyListeners();

      if (response.data['action'] == 'guide_to_bruno') {
        //Provider.of<NavigationService>(context, listen: false).goBruno();
      } else if (response.data['action'] == 'guide_to_bizy') {
        final summary = await FirebaseFunctions.instance
            .httpsCallable('update_summary')
            .call({"dialogues": _dialogues, "action": 'guide_to_bizy'});

        // _repository.addSummary(sparky!.id, summary.toString());
        showBizyButton = true;
        //notifyListeners();
      }
    } catch (e) {
      print('Error handling submission: $e');
    }
  }
}
