import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // 添加这一行

class BizyViewModel {
  bool _isLoading = false;
  final id = '1';
  String agentOutput = '';
  String bizyType = 'bizy_main';

  List<Map<String, String>> _dialogues = [];

  Future<void> _loadData() async {
    //setState(() => _isLoading = true);
    try {
      var response = await FirebaseFunctions.instance
          .httpsCallable('bizy_completion')
          .call(
        {"dialogues": _dialogues, "user_id": id, "bizy_type": bizyType},
      );
      // setState(() {
      //   agentOutput = response.data.toString();
      //   _dialogues.add({'role': 'assistant', 'content': agentOutput});
      // });

      if (response.data['action'] == 'analysis') {
        // setState(() {
        //   bizyType = 'bizy_analysis';
        // });
        response = await FirebaseFunctions.instance
            .httpsCallable('bizy_completion')
            .call(
          {"dialogues": _dialogues, "user_id": id, "bizy_type": bizyType},
        );
        // setState(() {
        //   agentOutput = response.data.toString();
        //   _dialogues.add({'role': 'assistant', 'content': agentOutput});
        // });
      }
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

    var response =
        await FirebaseFunctions.instance.httpsCallable('bizy_completion').call({
      "dialogues": _dialogues,
      "user_id": id,
      "bizy_type": bizyType,
    });
    // setState(() {
    //   agentOutput = response.data.toString();
    //   _dialogues.add({'role': 'assistant', 'content': agentOutput});
    // });

    if (response.data['action'] == 'finish_analysis') {
      // setState(() {
      //   bizyType = 'bizy_main';
      // });
      print('finish_analysis');
    }
    if (response.data['action'] == 'analysis') {
      // setState(() {
      //   bizyType = 'bizy_analysis';
      // });
      try {
        response = await FirebaseFunctions.instance
            .httpsCallable('bizy_completion')
            .call({
          "dialogues": _dialogues,
          "user_id": id,
          "bizy_type": bizyType,
        });
        // setState(() {
        //   agentOutput = response.data.toString();
        //   _dialogues.add({'role': 'assistant', 'content': agentOutput});
        // });
      } catch (e) {
        print('Error in second call: $e');
      }
    }
  }
}
