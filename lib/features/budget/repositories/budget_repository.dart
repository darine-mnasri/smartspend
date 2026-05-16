import 'package:dio/dio.dart';
import '../../../core/utils/dio_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../models/budget.dart';

class BudgetRepository {
  final DioClient _dio = DioClient();

  Future<List<Budget>> getBudgets() async {
    try {
      final response = await _dio.get('/budget/');
      return (response.data as List)
          .map((e) => Budget.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  Future<void> addBudget({
    required String categorie,
    required double plafond,
  }) async {
    try {
      await _dio.post('/budget/', data: {
        'categorie': categorie,
        'plafond':   plafond,
      });
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  Future<void> updateBudget({
    required int    id,
    required double plafond,
  }) async {
    try {
      await _dio.put('/budget/$id', data: {'plafond': plafond});
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _dio.delete('/budget/$id');
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }
}