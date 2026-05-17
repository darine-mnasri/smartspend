import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/dio_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../models/anomalie.dart';
import '../../transactions/providers/transaction_provider.dart';

class AnomalyState {
  final List<Anomalie> anomalies;
  final bool           isLoading;
  final String?        error;

  const AnomalyState({
    this.anomalies = const [],
    this.isLoading = false,
    this.error,
  });

  AnomalyState copyWith({
    List<Anomalie>? anomalies,
    bool?           isLoading,
    String?         error,
  }) {
    return AnomalyState(
      anomalies: anomalies ?? this.anomalies,
      isLoading: isLoading ?? this.isLoading,
      error:     error,
    );
  }
}

class AnomalyNotifier extends Notifier<AnomalyState> {
  final _dio = DioClient();

  @override
  AnomalyState build() {

    // ✅ Écoute automatique transactionProvider
    ref.listen<TransactionState>(
      transactionProvider,
      (previous, next) {
        if (previous?.transactions.length != next.transactions.length) {
          loadAnomalies();
        }
      },
    );

    Future.microtask(() => loadAnomalies());
    return const AnomalyState();
  }

  Future<void> loadAnomalies() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/anomalies/');
      final list = (response.data['anomalies'] as List)
          .map((e) => Anomalie.fromJson(e))
          .toList();
      state = state.copyWith(anomalies: list, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: (e.error as AppException?)?.message ?? 'Erreur',
      );
    }
  }
}

final anomalyProvider = NotifierProvider<AnomalyNotifier, AnomalyState>(
  AnomalyNotifier.new,
);