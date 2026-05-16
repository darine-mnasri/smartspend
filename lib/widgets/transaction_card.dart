import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/transaction.dart';
import '../core/constants/app_colors.dart';
import 'category_badge.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;
  final int index;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (index * 60).ms),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end:   Offset.zero,
          duration: 300.ms,
          delay: (index * 60).ms,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:       Colors.black.withOpacity(0.05),
              blurRadius:  10,
              offset:      const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8,
          ),
          leading: Container(
            width:  48,
            height: 48,
            decoration: BoxDecoration(
              color: (AppColors.categoryColors[transaction.categorie] ??
                      AppColors.categoryColors['Autre']!)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(transaction.categorie ?? 'Autre'),
              color: AppColors.categoryColors[transaction.categorie] ??
                     AppColors.categoryColors['Autre']!,
            ),
          ),
          title: Text(
            transaction.description,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize:   15,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              CategoryBadge(categorie: transaction.categorie),
              const SizedBox(height: 2),
              Text(
                transaction.dateTransaction,
                style: TextStyle(
                  fontSize: 11,
                  color:    Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.montant.toStringAsFixed(2)} DT',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:   16,
                  color:      AppColors.error,
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_outline,
                    size:  18,
                    color: Colors.grey[400],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String cat) {
    switch (cat) {
      case 'Alimentation': return Icons.restaurant;
      case 'Transport':    return Icons.directions_car;
      case 'Loisirs':      return Icons.sports_esports;
      case 'Sante':        return Icons.medical_services;
      case 'Shopping':     return Icons.shopping_bag;
      case 'Logement':     return Icons.home;
      default:             return Icons.category;
    }
  }
}