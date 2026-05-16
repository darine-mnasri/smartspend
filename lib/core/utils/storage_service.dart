import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  // Clés de stockage
  static const String _tokenKey = 'jwt_token';
  static const String _userKey  = 'user_data';

  // Référence à la boîte Hive ouverte dans main.dart
  static Box get _box => Hive.box('smartspend');

  // ── Sauvegarder le token après login
  static Future<void> saveToken(String token) async {
    await _box.put(_tokenKey, token);
  }

  // ── Lire le token (retourne null si pas connecté)
  static String? getToken() {
    return _box.get(_tokenKey);
  }

  // ── Supprimer le token au logout
  static Future<void> deleteToken() async {
    await _box.delete(_tokenKey);
  }

  // ── Vérifier si l'user est connecté
  static bool isLoggedIn() {
    return _box.get(_tokenKey) != null;
  }
}