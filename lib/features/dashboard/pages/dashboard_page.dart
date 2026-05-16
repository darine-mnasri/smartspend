import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/transactions/providers/transaction_provider.dart';
import '../../../features/anomalies/providers/anomaly_provider.dart';
import '../../../features/budget/providers/budget_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transState  = ref.watch(transactionProvider);
    final anomState   = ref.watch(anomalyProvider);
    final budgetState = ref.watch(budgetProvider);
    final authState   = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [

          // ── AppBar avec dégradé
          SliverAppBar(
            expandedHeight: 140,
            floating:       false,
            pinned:         true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF0D7A5A)],
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:  MainAxisAlignment.end,
                      children: [
                        Text(
                          'Bonjour, ${authState.user?.nom ?? ''} 👋',
                          style: const TextStyle(
                            color:      Colors.white70,
                            fontSize:   14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr('dashboard'),
                          style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Cards résumé
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: tr('total_expenses'),
                          value: '${transState.total.toStringAsFixed(2)} DT',
                          icon:  Icons.trending_down,
                          color: AppColors.error,
                          index: 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: tr('anomalies_detected'),
                          value: '${anomState.anomalies.length}',
                          icon:  Icons.warning_amber,
                          color: AppColors.warning,
                          index: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: tr('transactions'),
                          value:  '${transState.transactions.length}',
                          icon:   Icons.receipt_long,
                          color:  AppColors.primary,
                          index:  2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: tr('budget'),
                          value: '${budgetState.budgets.length}',
                          icon:  Icons.pie_chart,
                          color: AppColors.secondary,
                          index: 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── PieChart
                  if (transState.byCategory.isNotEmpty) ...[
                    _SectionTitle(title: tr('expenses_by_category')),
                    const SizedBox(height: 12),
                    _PieChartWidget(byCategory: transState.byCategory),
                    const SizedBox(height: 24),
                  ],

                  // ── LineChart
                  if (transState.transactions.length >= 2) ...[
                    _SectionTitle(title: tr('expenses_evolution')),
                    const SizedBox(height: 12),
                    _LineChartWidget(
                      transactions: transState.transactions
                          .map((t) => {
                                'montant': t.montant,
                                'date':    t.dateTransaction,
                              })
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Dernières transactions
                  if (transState.transactions.isNotEmpty) ...[
                    _SectionTitle(title: tr('last_transactions')),
                    const SizedBox(height: 12),
                    ...transState.transactions.take(5).map((t) =>
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:        Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:      Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: (AppColors.categoryColors[t.categorie]
                                        ?? AppColors.categoryColors['Autre']!)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.receipt,
                                size:  18,
                                color: AppColors.categoryColors[t.categorie]
                                    ?? AppColors.categoryColors['Autre']!,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize:   13,
                                      )),
                                  Text(t.categorie ?? 'Autre',
                                      style: TextStyle(
                                        color:    Colors.grey[500],
                                        fontSize: 11,
                                      )),
                                ],
                              ),
                            ),
                            Text(
                              '${t.montant.toStringAsFixed(2)} DT',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color:      AppColors.error,
                                fontSize:   14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget carte résumé
class _SummaryCard extends StatelessWidget {
  final String    title;
  final String    value;
  final IconData  icon;
  final Color     color;
  final int       index;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 400.ms, delay: (index * 80).ms),
        ScaleEffect(
          begin: const Offset(0.9, 0.9),
          end:   const Offset(1.0, 1.0),
          duration: 400.ms,
          delay: (index * 80).ms,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:        color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize:   22,
                fontWeight: FontWeight.bold,
                color:      color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color:    Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Titre de section
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            color:        AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize:   16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── PieChart
class _PieChartWidget extends StatefulWidget {
  final Map<String, double> byCategory;
  const _PieChartWidget({required this.byCategory});

  @override
  State<_PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<_PieChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final entries = widget.byCategory.entries.toList();
    final total   = widget.byCategory.values.fold(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex = response?.touchedSection
                              ?.touchedSectionIndex ?? -1;
                    });
                  },
                ),
                sections: entries.asMap().entries.map((e) {
                  final i      = e.key;
                  final entry  = e.value;
                  final color  = AppColors.categoryColors[entry.key]
                      ?? AppColors.categoryColors['Autre']!;
                  final isTouched = i == _touchedIndex;
                  final pct    = (entry.value / total * 100).toStringAsFixed(1);

                  return PieChartSectionData(
                    color:      color,
                    value:      entry.value,
                    title:      isTouched ? '$pct%' : '',
                    radius:     isTouched ? 80 : 65,
                    titleStyle: const TextStyle(
                      color:      Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize:   13,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace:     3,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Légende
          Wrap(
            spacing: 12, runSpacing: 8,
            children: entries.map((e) {
              final color = AppColors.categoryColors[e.key]
                  ?? AppColors.categoryColors['Autre']!;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color:  color,
                      shape:  BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${e.key} (${e.value.toStringAsFixed(0)} DT)',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── LineChart
class _LineChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  const _LineChartWidget({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final spots = transactions.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value['montant'] as double);
    }).toList();

    final maxY = transactions
        .map((t) => t['montant'] as double)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY * 1.2,
            gridData: FlGridData(
              show:                 true,
              drawVerticalLine:     false,
              horizontalInterval:   maxY / 4,
              getDrawingHorizontalLine: (_) => FlLine(
                color:       Colors.grey[200]!,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles:    true,
                  reservedSize:  40,
                  getTitlesWidget: (value, _) => Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color:    Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles:   AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots:          spots,
                isCurved:       true,
                color:          AppColors.primary,
                barWidth:       3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show:          true,
                  getDotPainter: (spot, _, __, ___) =>
                      FlDotCirclePainter(
                        radius:      4,
                        color:       AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                ),
                belowBarData: BarAreaData(
                  show:  true,
                  color: AppColors.primary.withOpacity(0.08),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}