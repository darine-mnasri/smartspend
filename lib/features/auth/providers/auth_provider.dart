import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../../../core/utils/storage_service.dart';
import '../repositories/auth_repository.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../budget/providers/budget_provider.dart';
import '../../anomalies/providers/anomaly_provider.dart';

class AuthState {
  final User?   user;
  final bool    isLoading;
  final String? error;
  final bool    isLoggedIn;

  const AuthState({
    this.user,
    this.isLoading  = false,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    User?   user,
    bool?   isLoading,
    String? error,
    bool?   isLoggedIn,
  }) {
    return AuthState(
      user:       user       ?? this.user,
      isLoading:  isLoading  ?? this.isLoading,
      error:      error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = AuthRepository();
    final isLoggedIn = StorageService.isLoggedIn();
    return AuthState(isLoggedIn: isLoggedIn);
  }

  // ✅ Réinitialise tous les providers de données
  void _resetAllProviders() {
    ref.read(transactionProvider.notifier).reset();
    ref.read(budgetProvider.notifier).reset();
    ref.read(anomalyProvider.notifier).reset();
    ref.invalidate(transactionProvider);
    ref.invalidate(budgetProvider);
    ref.invalidate(anomalyProvider);
  }

  Future<bool> register({
    required String nom,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.register(
        nom:      nom,
        email:    email,
        password: password,
      );
      state = state.copyWith(isLoading: false, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.login(
        email:    email,
        password: password,
      );

      // ✅ Réinitialiser les providers AVANT de changer l'état
      // pour que les nouveaux providers chargent avec le nouveau token
      _resetAllProviders();

      state = state.copyWith(
        isLoading:  false,
        user:       user,
        isLoggedIn: true,
        error:      null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();

    // ✅ Vider tous les providers au logout
    _resetAllProviders();

    // Reset complet de l'état auth
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);