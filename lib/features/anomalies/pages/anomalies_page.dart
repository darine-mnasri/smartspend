import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/anomaly_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/anomalie.dart';

class AnomaliesPage extends ConsumerWidget {
  const AnomaliesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(anomalyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('anomalies')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(anomalyProvider.notifier).loadAnomalies(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.primary))
          : state.anomalies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(tr('no_anomalies'),
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.anomalies.length,
                  itemBuilder: (ctx, i) {
                    final a = state.anomalies[i];
                    return _AnomalyCard(anomalie: a, index: i);
                  },
                ),
    );
  }
}

class _AnomalyCard extends StatelessWidget {
  final Anomalie anomalie;
  final int      index;

  const _AnomalyCard({required this.anomalie, required this.index});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (index * 80).ms),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          duration: 300.ms,
          delay: (index * 80).ms,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color:      AppColors.error.withOpacity(0.08),
              blurRadius: 10,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:        AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_amber,
                        color: AppColors.error, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anomalie.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:   15,
                          ),
                        ),
                        Text(
                          anomalie.dateTransaction,
                          style: TextStyle(
                            color:    Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${anomalie.montant.toStringAsFixed(2)} DT',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:   18,
                      color:      AppColors.error,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Stats Z-score
              Row(
                children: [
                  _StatChip(
                    label: tr('average'),
                    value: '${anomalie.moyenne.toStringAsFixed(2)} DT',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: tr('threshold'),
                    value: '${anomalie.seuil.toStringAsFixed(2)} DT',
                    color: AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Message
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:        AppColors.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        anomalie.message,
                        style: const TextStyle(
                          color:    AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}