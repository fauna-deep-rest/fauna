import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sparky.dart';

class SparkyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createSparky(String sparkyId) async {
    try {
      final sparkyMap = {
        'id': sparkyId,
        'summary': [],
      };
      await _firestore.collection('sparky').doc(sparkyId).set(sparkyMap);
    } catch (e) {
      print("Create Sparky failed!");
    }
  }

  Future<Sparky?> fetchSparky(String sparkyId) async {
    try {
      final doc = await _firestore.collection('sparky').doc(sparkyId).get();
      if (doc.exists) {
        return Sparky.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching Sparky: $e');
    }
    return null;
  }

  Future<void> saveSparky(Sparky sparky) async {
    try {
      await _firestore.collection('sparky').doc(sparky.id).set(sparky.toMap());
    } catch (e) {
      print('Error saving Sparky: $e');
    }
  }

  Future<void> addSummary(String sparkyId, String newSummary) async {
    try {
      await _firestore.collection('sparky').doc(sparkyId).update({
        'summary': FieldValue.arrayUnion([newSummary]),
      });
    } catch (e) {
      print('Error adding summary to Sparky: $e');
    }
  }

  Future<void> clearSummary(String sparkyId) async {
    try {
      await _firestore.collection('sparky').doc(sparkyId).update({
        'summary': [],
      });
    } catch (e) {
      print('Error clearing Sparky summary: $e');
    }
  }
}
