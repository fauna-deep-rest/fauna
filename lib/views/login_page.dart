import 'package:fauna/view_model/bizy_view_model.dart';
import 'package:fauna/view_model/bruno_view_model.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/navigation.dart';
import '../view_model/user_view_model.dart';
import '../view_model/sparky_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String userId = '01';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userViewModel =
          Provider.of<AllUsersViewModel>(context, listen: false);
      final sparkyViewModel =
          Provider.of<SparkyViewModel>(context, listen: false);
      final bizyViewModel = Provider.of<BizyViewModel>(context, listen: false);
      final brunoViewModel =
          Provider.of<BrunoViewModel>(context, listen: false);
      final user = await userViewModel
          .getUserById(userId); // If user exists, current user will be set here

      if (user == null) {
        await sparkyViewModel.createSparky('sparky_$userId');
        await bizyViewModel.createBizy('bizy_$userId');
        await brunoViewModel.createBruno('bruno_$userId');
        await userViewModel.addUser(
            userId,
            "Test User $userId",
            "sparky_$userId",
            'bruno_$userId',
            "bizy_$userId"); // If user not exists, current user will be set here
        print("create new user $userId");
      }

      Provider.of<NavigationService>(context, listen: false).goHome();
    } catch (e) {
      print("Login Failed");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // 跳轉到註冊頁面邏輯
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
