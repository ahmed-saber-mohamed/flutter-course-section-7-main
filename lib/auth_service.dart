import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'anime_users';
  static const String _currentUserKey = 'current_anime_user';

  static Future<Map<String, dynamic>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null) return {};

    try {
      final decoded = jsonDecode(usersJson);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  static Future<bool> signup(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getUsers();

    if (users.containsKey(username)) return false;

    users[username] = {
      'password': password,
      'favorites': <String>[],
    };

    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_currentUserKey, username);

    return true;
  }

  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getUsers();

    if (!users.containsKey(username)) return false;

    if (users[username]['password'] != password) return false;

    await prefs.setString(_currentUserKey, username);
    return true;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  static Future<List<String>> getFavorites() async {
    final username = await getCurrentUser();
    if (username == null) return [];

    final users = await _getUsers();
    final user = users[username];

    if (user == null) return [];

    return List<String>.from(user['favorites'] ?? []);
  }

  static Future<void> addFavorite(String animeId) async {
    await _updateFavorites(animeId, true);
  }

  static Future<void> removeFavorite(String animeId) async {
    await _updateFavorites(animeId, false);
  }

  static Future<void> _updateFavorites(
    String animeId,
    bool add,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_currentUserKey);

    if (username == null) return;

    final users = await _getUsers();
    final user = users[username];

    if (user == null) return;

    final favorites = List<String>.from(user['favorites'] ?? []);

    if (add) {
      if (!favorites.contains(animeId)) {
        favorites.add(animeId);
      }
    } else {
      favorites.remove(animeId);
    }

    user['favorites'] = favorites;
    users[username] = user;

    await prefs.setString(_usersKey, jsonEncode(users));
  }
}