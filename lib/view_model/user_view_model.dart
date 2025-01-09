import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/user_repo.dart';

class AllUsersViewModel with ChangeNotifier {
  final UserRepository _userRepository;
  late User currentUser;

  AllUsersViewModel({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  @override
  void dispose() {
    super.dispose();
  }

  Future<User?> getUserById(String userId) async {
    try {
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        currentUser = user;
        print("Set current user in getUserById");
      }
      return user;
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  Future<void> addUser(String userId, String name, String sparkyId) async {
    try {
      final newUser = await _userRepository.addUser(userId, name, sparkyId);
      currentUser = newUser;
      print("Set current user in addUser");
    } catch (e) {
      print('Failed to add user: $e');
    }
  }
}
