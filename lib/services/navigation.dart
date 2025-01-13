import 'package:fauna/views/chat_page/bizy/bizy_chat_page.dart';
import 'package:fauna/views/chat_page/bruno/bruno_chat_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fauna/views/login_page.dart';
import 'package:fauna/views/homepage.dart';
import 'package:fauna/views/chat_page/sparky_chat_page.dart';
import 'package:fauna/view_model/sparky_view_model.dart';
import 'package:fauna/view_model/user_view_model.dart';
import 'package:fauna/view_model/bruno_view_model.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String sparky = '/sparky';
  static const String bizy = '/bizy';
  static const String bruno = '/bruno';
}

final routerConfig = GoRouter(
  routes: <RouteBase>[
    ShellRoute(
        //let all sub-paths share parent components like view model
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AllUsersViewModel()),
              ChangeNotifierProvider(create: (_) => SparkyViewModel()),
              ChangeNotifierProvider(create: (_) => BrunoViewModel()),
            ],
            child: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
              path: AppRoutes.login, builder: (context, state) => LoginPage()),
          GoRoute(
              path: AppRoutes.home, builder: (context, state) => HomePage()),
          GoRoute(
              path: AppRoutes.sparky,
              builder: (context, state) => SparkyChatPage()),
          GoRoute(
              path: AppRoutes.bizy,
              builder: (context, state) => BizyChatPage()),
          GoRoute(
              path: AppRoutes.bruno,
              builder: (context, state) => BrunoChatPage()),
        ]),
  ],
  initialLocation: AppRoutes.login,
  debugLogDiagnostics: true,
  redirect: (context, state) {
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('頁面未找到: ${state.uri.path}'),
    ),
  ),
);

class NavigationService {
  late final GoRouter _router;

  NavigationService() {
    _router = routerConfig;
  }

  void goHome() {
    _router.go('/home');
  }

  void goLogin() {
    _router.go('/');
  }

  void goSparky() {
    _router.go('/sparky');
  }

  void goBizy() {
    _router.go('/bizy');
  }

  void goBruno() {
    _router.go('/bruno');
  }

  void pop(BuildContext context) {
    _router.pop(context);
  }
}
