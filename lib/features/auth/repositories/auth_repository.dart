import '../../../core/utils/dio_client.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/errors/app_exception.dart';
import '../../../models/user.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final DioClient _dio = DioClient();

  // ── Register
  Future<void> register({
    required String nom,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post('/auth/register', data: {
        'nom':      nom,
        'email':    email,
        'password': password,
      });
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  // ── Login → retourne User + sauvegarde token
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email':    email,
        'password': password,
      });

      // Sauvegarder le token JWT dans Hive
      final token = response.data['token'];
      await StorageService.saveToken(token);

      // Retourner l'objet User
      return User.fromJson(response.data['user']);

    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  // ── Logout → supprimer le token
  Future<void> logout() async {
    await StorageService.deleteToken();
  }
}