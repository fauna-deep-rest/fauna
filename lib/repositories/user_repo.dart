import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final timeout = const Duration(seconds: 10);

  Future<User> addUser(String userId, String name, String sparkyId,
      String brunoId, String bizyId) async {
    Map<String, dynamic> userMap = {
      'name': name,
      'sparkyId': sparkyId,
      'brunoId': brunoId,
      'bizyId': bizyId,
    };
    await _db
        .collection('users')
        .doc(userId)
        .set(userMap); // write to local cache immediately
    //.timeout(timeout); // Add timeout to handle network issues
    return User(
        id: userId, name: name, sparkyId: sparkyId, brunoId: "", bizyId: "");
  }

  Future<User?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }
}
