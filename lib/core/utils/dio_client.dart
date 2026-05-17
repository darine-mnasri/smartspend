import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/app_exception.dart';
import 'storage_service.dart';

class DioClient {
  // Instance unique (singleton)
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  // Instance Dio configurée
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),  
      receiveTimeout: const Duration(seconds: 10),  
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(
    InterceptorsWrapper(

      // ── Avant chaque requête → ajouter le token JWT
      onRequest: (options, handler) {
        final token = StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print(' ${options.method} ${options.path}');
        return handler.next(options);
      },

      // ── Réponse reçue 
      onResponse: (response, handler) {
        print(' ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },

      // ── Erreur → convertir en AppException lisible
      onError: (error, handler) {
        print(' Erreur : ${error.message}');

        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: AppException.timeout(),
            ),
          );
        }

        if (error.type == DioExceptionType.connectionError) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: AppException.network(),
            ),
          );
        }

        // Erreur HTTP (400, 401, 500...)
        final statusCode   = error.response?.statusCode;
        final serverMessage = error.response?.data['message'];
        return handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            error: AppException.fromStatusCode(statusCode, serverMessage),
          ),
        );
      },
    ),
  );

  // ── Méthodes publiques utilisées dans les repositories

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}