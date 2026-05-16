import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/dio_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../models/anomalie.dart';

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
  final DioClient _dio = DioClient();
  int _generation = 0;

  @override
  AnomalyState build() {
    Future.microtask(() => loadAnomalies());
    return const AnomalyState();
  }

  void reset() {
    _generation++;
    state = const AnomalyState();
  }

  Future<void> loadAnomalies() async {
    final generation = _generation;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/anomalies/');
      if (generation != _generation) return;
      final list = (response.data['anomalies'] as List)
          .map((e) => Anomalie.fromJson(e))
          .toList();
      state = state.copyWith(anomalies: list, isLoading: false);
    } on DioException catch (e) {
      if (generation != _generation) return;
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