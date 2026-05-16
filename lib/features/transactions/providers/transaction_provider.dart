import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionState {
  final List<Transaction> transactions;
  final bool              isLoading;
  final String?           error;

  const TransactionState({
    this.transactions = const [],
    this.isLoading    = false,
    this.error,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    bool?              isLoading,
    String?            error,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading:    isLoading    ?? this.isLoading,
      error:        error,
    );
  }

  double get total =>
      transactions.fold(0, (sum, t) => sum + t.montant);

  Map<String, double> get byCategory {
    final Map<String, double> map = {};
    for (final t in transactions) {
      final cat = t.categorie ?? 'Autre';
      map[cat] = (map[cat] ?? 0) + t.montant;
    }
    return map;
  }
}

class TransactionNotifier extends Notifier<TransactionState> {
  final TransactionRepository _repository = TransactionRepository();
  int _generation = 0;

  @override
  TransactionState build() {
    // Chargement automatique au démarrage
    Future.microtask(() => loadTransactions());
    return const TransactionState();
  }

  void reset() {
    _generation++;
    state = const TransactionState();
  }

  Future<void> loadTransactions() async {
    final generation = _generation;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getTransactions();
      if (generation != _generation) return;
      state = state.copyWith(transactions: list, isLoading: false);
    } catch (e) {
      if (generation != _generation) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addTransaction({
    required String description,
    required double montant,
    required String date,
  }) async {
    final generation = _generation;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newT = await _repository.addTransaction(
        description: description,
        montant:     montant,
        date:        date,
      );
      if (generation != _generation) return false;
      state = state.copyWith(
        transactions: [newT, ...state.transactions],
        isLoading:    false,
      );
      return true;
    } catch (e) {
      if (generation != _generation) return false;
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      await _repository.deleteTransaction(id);
      state = state.copyWith(
        transactions: state.transactions
            .where((t) => t.id != id)
            .toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final transactionProvider =
    NotifierProvider<TransactionNotifier, TransactionState>(
  TransactionNotifier.new,
);