import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bizy.dart';

class BizyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBizy(String bizyId) async {
    try {
      final bizyMap = {
        'id': bizyId,
        'summary': [],
        'todo_list': [],
        'procrastination_type': '',
      };
      await _firestore.collection('bizy').doc(bizyId).set(bizyMap);
    } catch (e) {
      print("Create Bizy failed!");
    }
  }

  Future<Bizy?> fetchBizy(String bizyId) async {
    try {
      final doc = await _firestore.collection('bizy').doc(bizyId).get();
      if (doc.exists) {
        return Bizy.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching Bizy: $e');
    }
    return null;
  }

  Future<void> saveBizy(Bizy bizy) async {
    try {
      await _firestore.collection('bizy').doc(bizy.id).set(bizy.toMap());
    } catch (e) {
      print('Error saving Bizy: $e');
    }
  }

  Future<void> addSummary(String bizyId, String newSummary) async {
    try {
      await _firestore.collection('bizy').doc(bizyId).update({
        'summary': FieldValue.arrayUnion([newSummary]),
      });
    } catch (e) {
      print('Error adding summary to Bizy: $e');
    }
  }

  Future<void> clearSummary(String bizyId) async {
    try {
      await _firestore.collection('bizy').doc(bizyId).update({
        'summary': [],
      });
    } catch (e) {
      print('Error clearing Bizy summary: $e');
    }
  }

  Future<void> updateTodoList(
      String bizyId, List<Map<String, dynamic>> newTodoList) async {
    try {
      await _firestore.collection('bizy').doc(bizyId).update({
        'todo_list': newTodoList,
      });
    } catch (e) {
      print('Error updating Bizy todo list: $e');
    }
  }

  Future<void> setProcrastinationType(String bizyId, String type) async {
    try {
      await _firestore.collection('bizy').doc(bizyId).update({
        'procrastination_type': type,
      });
    } catch (e) {
      print('Error setting Bizy procrastination type: $e');
    }
  }
}
