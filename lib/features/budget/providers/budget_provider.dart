import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/budget.dart';
import '../repositories/budget_repository.dart';
import '../../transactions/providers/transaction_provider.dart';

class BudgetState {
  final List<Budget>          budgets;
  final bool                  isLoading;
  final String?               error;
  // Dépenses réelles par catégorie — calculées depuis transactions
  final Map<String, double>   depensesParCategorie;

  const BudgetState({
    this.budgets              = const [],
    this.isLoading            = false,
    this.error,
    this.depensesParCategorie = const {},
  });

  BudgetState copyWith({
    List<Budget>?         budgets,
    bool?                 isLoading,
    String?               error,
    Map<String, double>?  depensesParCategorie,
  }) {
    return BudgetState(
      budgets:              budgets              ?? this.budgets,
      isLoading:            isLoading            ?? this.isLoading,
      error:                error,
      depensesParCategorie: depensesParCategorie ?? this.depensesParCategorie,
    );
  }

  // Calcule le budget restant pour une catégorie
  double resteFor(String categorie, double plafond) {
    final depense = depensesParCategorie[categorie] ?? 0;
    return plafond - depense;
  }

  // Pourcentage utilisé pour une catégorie (pour la barre de progression)
  double percentFor(String categorie, double plafond) {
    if (plafond == 0) return 0;
    final depense = depensesParCategorie[categorie] ?? 0;
    return (depense / plafond).clamp(0.0, 1.0);
  }
}

class BudgetNotifier extends Notifier<BudgetState> {
  final BudgetRepository _repository = BudgetRepository();
  int _generation = 0;

  @override
  BudgetState build() {
    // ✅ Écoute automatique — si transactions changent → recalculer dépenses
    ref.listen<TransactionState>(
      transactionProvider,
      (previous, next) {
        if (previous?.transactions != next.transactions) {
          // Mettre à jour les dépenses par catégorie
          state = state.copyWith(
            depensesParCategorie: next.byCategory,
          );
        }
      },
    );

    Future.microtask(() => loadBudgets());
    return const BudgetState();
  }

  void reset() {
    _generation++;
    state = const BudgetState();
  }

  Future<void> loadBudgets() async {
    final generation = _generation;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getBudgets();

      if (generation != _generation) return;

      // Lire les dépenses actuelles depuis transactionProvider
      Map<String, double> depenses = const {};
      try {
        depenses = ref.read(transactionProvider).byCategory;
      } catch (_) {
        depenses = const {};
      }

      state = state.copyWith(
        budgets:              list,
        isLoading:            false,
        depensesParCategorie: depenses,
      );
    } catch (e) {
      if (generation != _generation) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addBudget({
    required String categorie,
    required double plafond,
  }) async {
    final generation = _generation;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addBudget(categorie: categorie, plafond: plafond);
      await loadBudgets();
      return true;
    } catch (e) {
      if (generation != _generation) return false;
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateBudget({
    required int    id,
    required double plafond,
  }) async {
    try {
      await _repository.updateBudget(id: id, plafond: plafond);
      await loadBudgets();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteBudget(int id) async {
    try {
      await _repository.deleteBudget(id);
      state = state.copyWith(
        budgets: state.budgets.where((b) => b.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(
  BudgetNotifier.new,
);