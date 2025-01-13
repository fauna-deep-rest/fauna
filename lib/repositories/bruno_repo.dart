/// BrunoRepository handles all Bruno-related operations with Firestore database
/// Including methods for creating, reading, and updating Bruno documents
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bruno.dart';

class BrunoRepository {
  /// Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new Bruno document
  /// @param brunoId - Unique identifier for Bruno
  /// @return Future<void>
  Future<void> createBruno(String brunoId) async {
    try {
      final brunoMap = {
        'id': brunoId,
        'records': [],
        'summary': [],
      };
      await _firestore.collection('bruno').doc(brunoId).set(brunoMap);
    } catch (e) {
      print("Create Bruno failed: $e");
    }
  }

  /// Fetches a specific Bruno document from Firestore
  /// @param brunoId - Unique identifier for Bruno
  /// @return Future<Bruno?> - Returns Bruno object, null if not found
  Future<Bruno?> fetchBruno(String brunoId) async {
    try {
      final doc = await _firestore.collection('bruno').doc(brunoId).get();
      if (doc.exists) {
        return Bruno.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching Bruno: $e');
    }
    return null;
  }

  /// Saves Bruno object to Firestore
  /// @param bruno - Bruno object to save
  /// @return Future<void>
  Future<void> saveBruno(Bruno bruno) async {
    try {
      await _firestore.collection('bruno').doc(bruno.id).set(bruno.toMap());
    } catch (e) {
      print('Error saving Bruno: $e');
    }
  }

  /// Adds a summary to Bruno document
  /// @param brunoId - Unique identifier for Bruno
  /// @param newSummary - Summary text to add
  /// @return Future<void>
  Future<void> addSummary(String brunoId, String newSummary) async {
    try {
      await _firestore.collection('bruno').doc(brunoId).update({
        'summary': FieldValue.arrayUnion([newSummary]),
      });
    } catch (e) {
      print('Error adding summary to Bruno: $e');
    }
  }

  /// Adds a record to Bruno document
  /// @param brunoId - Unique identifier for Bruno
  /// @param record - Record object to add
  /// @return Future<void>
  Future<void> addRecord(String brunoId, Record record) async {
    try {
      await _firestore.collection('bruno').doc(brunoId).update({
        'records': FieldValue.arrayUnion([record.toMap()]),
      });
    } catch (e) {
      print('Error adding record to Bruno: $e');
    }
  }

  /// Clears all summaries in Bruno document
  /// @param brunoId - Unique identifier for Bruno
  /// @return Future<void>
  Future<void> clearSummary(String brunoId) async {
    try {
      await _firestore.collection('bruno').doc(brunoId).update({
        'summary': [],
      });
    } catch (e) {
      print('Error clearing Bruno summary: $e');
    }
  }
}
