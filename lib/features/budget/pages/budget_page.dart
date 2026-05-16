import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/budget.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  static const List<String> _categories = [
    'Alimentation', 'Transport', 'Loisirs',
    'Sante', 'Shopping', 'Logement', 'Autre',
  ];

  static const Map<String, IconData> _icons = {
    'Alimentation': Icons.restaurant,
    'Transport':    Icons.directions_car,
    'Loisirs':      Icons.sports_esports,
    'Sante':        Icons.medical_services,
    'Shopping':     Icons.shopping_bag,
    'Logement':     Icons.home,
    'Autre':        Icons.category,
  };

  void _showAddDialog(BuildContext context, WidgetRef ref,
      {Budget? existing}) {
    final plafondCtrl = TextEditingController(
      text: existing != null ? existing.plafond.toString() : '',
    );
    String selectedCat = existing?.categorie ?? _categories[0];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            existing != null ? tr('edit_budget') : tr('set_budget'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown catégorie (seulement si nouveau)
              if (existing == null)
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: InputDecoration(
                    labelText: tr('category'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(
                          _icons[cat],
                          size:  18,
                          color: AppColors.categoryColors[cat],
                        ),
                        const SizedBox(width: 8),
                        Text(cat),
                      ],
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() => selectedCat = v!),
                ),
              if (existing == null) const SizedBox(height: 16),

              // Plafond
              TextField(
                controller:   plafondCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText:  tr('amount'),
                  suffixText: 'DT',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary, width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final val = double.tryParse(plafondCtrl.text);
                if (val == null || val <= 0) return;
                Navigator.pop(ctx);

                bool success;
                if (existing != null) {
                  success = await ref
                      .read(budgetProvider.notifier)
                      .updateBudget(id: existing.id, plafond: val);
                } else {
                  success = await ref
                      .read(budgetProvider.notifier)
                      .addBudget(categorie: selectedCat, plafond: val);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? tr('success_budget')
                          : ref.read(budgetProvider).error ?? 'Erreur'),
                      backgroundColor:
                          success ? AppColors.primary : AppColors.error,
                    ),
                  );
                }
              },
              child: Text(tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('budget')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(budgetProvider.notifier).loadBudgets(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : state.budgets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pie_chart_outline,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        tr('no_budget'),
                        style: TextStyle(
                          color: Colors.grey[500], fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Appuyez sur + pour définir un plafond',
                        style: TextStyle(
                          color: Colors.grey[400], fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.budgets.length,
                  itemBuilder: (ctx, i) {
                    final b     = state.budgets[i];
                    final color = AppColors.categoryColors[b.categorie]
                        ?? AppColors.categoryColors['Autre']!;
                    final depense =
                        state.depensesParCategorie[b.categorie] ?? 0;
                    final reste  = state.resteFor(b.categorie, b.plafond);
                    final pct    = state.percentFor(b.categorie, b.plafond);

                    // Couleur barre selon pourcentage
                    final barColor = pct > 0.8
                        ? AppColors.error
                        : pct > 0.6
                            ? AppColors.warning
                            : color;

                    return Animate(
                      effects: [
                        FadeEffect(duration: 300.ms, delay: (i * 60).ms),
                        SlideEffect(
                          begin:    const Offset(0, 0.1),
                          end:      Offset.zero,
                          duration: 300.ms,
                          delay:    (i * 60).ms,
                        ),
                      ],
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color:        Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color:      Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset:     const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [

                              // ── Header
                              Row(
                                children: [
                                  // Icône catégorie
                                  Container(
                                    width:  46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _icons[b.categorie] ?? Icons.category,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Nom + plafond
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b.categorie,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:   15,
                                          ),
                                        ),
                                        Text(
                                          'Plafond : ${b.plafond.toStringAsFixed(2)} DT',
                                          style: TextStyle(
                                            color:    Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Boutons modifier/supprimer
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.secondary,
                                      size:  20,
                                    ),
                                    onPressed: () => _showAddDialog(
                                      context, ref, existing: b,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.error,
                                      size:  20,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          title: Text(tr('delete')),
                                          content: Text(
                                            '${tr('delete_budget_confirm')}\n"${b.categorie}"',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context, false),
                                              child: Text(tr('cancel')),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context, true),
                                              child: Text(
                                                tr('delete'),
                                                style: const TextStyle(
                                                  color: AppColors.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && ctx.mounted) {
                                        await ref
                                            .read(budgetProvider.notifier)
                                            .deleteBudget(b.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // ── Barre de progression
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value:      pct,
                                  minHeight:  8,
                                  backgroundColor: color.withOpacity(0.12),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    barColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // ── Dépensé / Reste
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Dépensé
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dépensé',
                                        style: TextStyle(
                                          color:    Colors.grey[400],
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        '${depense.toStringAsFixed(2)} DT',
                                        style: TextStyle(
                                          color:      barColor,
                                          fontSize:   14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Pourcentage
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: barColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${(pct * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color:      barColor,
                                        fontSize:   12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // Reste
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Reste',
                                        style: TextStyle(
                                          color:    Colors.grey[400],
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        '${reste.toStringAsFixed(2)} DT',
                                        style: TextStyle(
                                          color: reste < 0
                                              ? AppColors.error
                                              : AppColors.primary,
                                          fontSize:   14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // ── Alerte si dépassement
                              if (reste < 0) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.error.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber,
                                          color: AppColors.error, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Plafond dépassé de ${reste.abs().toStringAsFixed(2)} DT !',
                                        style: const TextStyle(
                                          color:      AppColors.error,
                                          fontSize:   12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon:  const Icon(Icons.add),
        label: Text(tr('set_budget')),
      ),
    );
  }
}