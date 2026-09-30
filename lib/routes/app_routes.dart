import 'package:flutter/material.dart';

import '../models/item.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      login => MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
        settings: settings,
      ),
      home => MaterialPageRoute<void>(
        builder: (_) => HomeScreen(),
        settings: settings,
      ),
      detail when settings.arguments is Item => MaterialPageRoute<void>(
        builder: (_) => DetailScreen(item: settings.arguments! as Item),
        settings: settings,
      ),
      _ => null,
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
