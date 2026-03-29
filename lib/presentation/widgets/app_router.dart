import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:my_app/presentation/providers/auth_provider.dart';
import 'package:my_app/presentation/screens/login_screen.dart';
import 'package:my_app/presentation/screens/signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/screens/employeePage.dart';
import 'package:my_app/presentation/widgets/mainLayout.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',

  redirect: (context, state) {
    final auth = context.read<AuthProvider>();

    final isLoggedIn = auth.isLoggedIn;

    final isAuthRoute =
        state.uri.toString() == '/login' || state.uri.toString() == '/signup';

    ///  Not logged in → allow login/signup only
    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    /// Already logged in → prevent going back to login/signup
    if (isLoggedIn && isAuthRoute) {
      return '/employee';
    }

    return null;
  },

  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),

        GoRoute(
          path: '/employee',
          builder: (context, state) => const EmployeePage(),
        ),
      ],
    ),
  ],
);
