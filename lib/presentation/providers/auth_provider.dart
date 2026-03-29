import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  final Box<UserModel> userBox = Hive.box<UserModel>('users');

  bool isLoading = false;
  String? error;

  ///  CHECK SESSION
  Future<void> checkLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      error = "Failed to load session";
    }

    notifyListeners();
  }

  ///  SIGNUP
  Future<void> signup(String username, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final cleanUsername = username.trim().toLowerCase();

      final exists = userBox.values.any(
        (u) => u.username.trim().toLowerCase() == cleanUsername,
      );

      if (exists) {
        throw Exception("User already exists");
      }

      await userBox.add(
        UserModel(username: cleanUsername, password: password.trim()),
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///  LOGIN
  Future<void> login(String username, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final user = userBox.values.firstWhere(
        (u) =>
            u.username.trim().toLowerCase() == username.trim().toLowerCase() &&
            u.password.trim() == password.trim(),
      );

      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('currentUser', user.username);
    } catch (e) {
      error = "Invalid username or password";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///  LOGOUT
  Future<void> logout() async {
    try {
      _isLoggedIn = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('currentUser');
    } catch (e) {
      error = "Logout failed";
    }

    notifyListeners();
  }
}
