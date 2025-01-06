import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final timeout = const Duration(seconds: 10);

  Future<void> addUser(User user) async {
    Map<String, dynamic> userMap = user.toMap();
    // Remove 'id' because Firestore automatically generates a unique document ID for each new document added to the collection.
    userMap.remove('id');
    await _db
        .collection('users')
        .doc("user_${user.id}")
        .set(userMap); // write to local cache immediately
    //.timeout(timeout); // Add timeout to handle network issues
  }
}
