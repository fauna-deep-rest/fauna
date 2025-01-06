import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/user_repo.dart';

class AllUsersViewModel with ChangeNotifier {
  final UserRepository _userRepository;
  User? currentUser;

  AllUsersViewModel({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> addUser(User newUser) async {
    await _userRepository.addUser(newUser);
    currentUser = newUser;
  }
}
