import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/tasks/presentation/pages/task_dashboard_page.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';
import '../../features/tasks/domain/entities/task_entity.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String createTask = '/tasks/create';
  static const String editTask = '/tasks/edit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashPage());
      case login:
        return _slide(const LoginPage());
      case register:
        return _slide(const RegisterPage());
      case dashboard:
        return _fade(const TaskDashboardPage());
      case createTask:
        return _modal(const TaskFormPage());
      case editTask:
        final task = settings.arguments as TaskEntity;
        return _modal(TaskFormPage(task: task));
      default:
        return _fade(const LoginPage());
    }
  }

  static PageRoute _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      );

  static PageRoute _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) {
          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(position: anim.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      );

  static PageRoute _modal(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) {
          final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(position: anim.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}
