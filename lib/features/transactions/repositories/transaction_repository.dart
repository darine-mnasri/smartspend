import 'package:dio/dio.dart';
import '../../../core/utils/dio_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../models/transaction.dart';

class TransactionRepository {
  final DioClient _dio = DioClient();

  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await _dio.get('/transactions/');
      return (response.data as List)
          .map((e) => Transaction.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  Future<Transaction> addTransaction({
    required String description,
    required double montant,
    required String date,
  }) async {
    try {
      final response = await _dio.post('/transactions/', data: {
        'description':      description,
        'montant':          montant,
        'date_transaction': date,
      });
      return Transaction.fromJson(response.data['transaction']);
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _dio.delete('/transactions/$id');
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }
}