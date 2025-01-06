import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // 添加这一行

class SparkyViewModel {
  bool _isLoading = false;
  final id = '1';
  String agentOutput = '';
  List<Map<String, String>> _dialogues = [];

  Future<void> _loadData() async {
    //setState(() => _isLoading = true);
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('sparky_completion')
          .call({"dialogues": _dialogues, "user_id": id});
      // setState(() {
      //   agentOutput = response.data.toString();
      //   _dialogues.add({'role': 'assistant', 'content': agentOutput});
      // });
    } catch (e) {
      print('Error loading prompt: $e');
    } finally {
      //setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit(String prompt) async {
    if (prompt.trim().isEmpty) return;
    // setState(() {
    //   _dialogues.add({'role': 'user', 'content': prompt});
    // });

    final response = await FirebaseFunctions.instance
        .httpsCallable('sparky_completion')
        .call({"dialogues": _dialogues, "user_id": id});

    if (response.data['action'] == 'guide_to_bizy') {
      await FirebaseFunctions.instance
          .httpsCallable('update_summary')
          .call({"dialogues": _dialogues});
    }

    // setState(() {
    //   agentOutput = response.data.toString();
    //   _dialogues.add({'role': 'assistant', 'content': agentOutput});
    //   if (response.data['action'] == 'guide_to_bruno') {
    //     Provider.of<NavigationService>(context, listen: false).goBruno();
    //   }
    //   if (response.data['action'] == 'guide_to_bizy') {
    //     _isLoading = true;
    //     Provider.of<NavigationService>(context, listen: false).goBizy();
    //   }
    // });
  }
}
