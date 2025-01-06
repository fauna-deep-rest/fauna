import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // 添加这一行

class BrunoViewModel {
  bool _isLoading = false;
  final id = '1';
  String agentOutput = '';
  List<Map<String, String>> _dialogues = [];

  Future<void> _loadData() async {
    //setState(() => _isLoading = true);
    try {
      var response = await FirebaseFunctions.instance
          .httpsCallable('bruno_completion')
          .call(
        {"dialogues": _dialogues, "user_id": id},
      );
      print(response);
      // setState(() {
      //   agentOutput = response.data.toString();
      //   _dialogues.add({'role': 'assistant', 'content': agentOutput});
      // });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      //setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit(String prompt) async {
    if (prompt.trim().isEmpty) return;
    // setState(() {
    //   _dialogues.add({'role': 'user', 'content': prompt});
    // });
    final response =
        await FirebaseFunctions.instance.httpsCallable('bruno_completion').call(
      {"dialogues": _dialogues, "user_id": id},
    );

    // setState(() {
    //   agentOutput = response.data.toString();
    //   _dialogues.add({'role': 'assistant', 'content': agentOutput});
    // });
  }
}
