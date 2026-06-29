import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const _usersKey = 'local_users';
  static const _currentUserKey = 'current_user';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    final List<dynamic> jsonList = jsonDecode(raw);
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await _prefs;
    prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final users = await _loadUsers();
    if (users.any((user) => user['username'] == username)) {
      return false;
    }

    users.add({
      'username': username,
      'email': email,
      'password': password,
    });

    await _saveUsers(users);
    return true;
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final users = await _loadUsers();
    final user = users.firstWhere(
      (user) =>
          user['username'] == username && user['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) return false;

    final prefs = await _prefs;
    prefs.setString(_currentUserKey, jsonEncode(user));
    return true;
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    prefs.remove(_currentUserKey);
  }

  Future<Map<String, dynamic>?> currentUser() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_currentUserKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
