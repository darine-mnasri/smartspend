import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/budget.dart';
import '../repositories/budget_repository.dart';
import '../../transactions/providers/transaction_provider.dart';

class BudgetState {
  final List<Budget>        budgets;
  final bool                isLoading;
  final String?             error;
  final Map<String, double> depensesParCategorie;

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

  double resteFor(String categorie, double plafond) {
    final depense = depensesParCategorie[categorie] ?? 0;
    return plafond - depense;
  }

  double percentFor(String categorie, double plafond) {
    if (plafond == 0) return 0;
    final depense = depensesParCategorie[categorie] ?? 0;
    return (depense / plafond).clamp(0.0, 1.0);
  }
}

class BudgetNotifier extends Notifier<BudgetState> {
  late final BudgetRepository _repository;

  @override
  BudgetState build() {
    _repository = BudgetRepository();

    // ✅ Écoute automatique transactions
    ref.listen<TransactionState>(
      transactionProvider,
      (previous, next) {
        if (previous?.transactions != next.transactions) {
          state = state.copyWith(
            depensesParCategorie: next.byCategory,
          );
        }
      },
    );

    Future.microtask(() => loadBudgets());
    return const BudgetState();
  }

  Future<void> loadBudgets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list    = await _repository.getBudgets();
      final depenses = ref.read(transactionProvider).byCategory;

      state = state.copyWith(
        budgets:              list,
        isLoading:            false,
        depensesParCategorie: depenses,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addBudget({
    required String categorie,
    required double plafond,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addBudget(categorie: categorie, plafond: plafond);
      await loadBudgets();
      return true;
    } catch (e) {
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