import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CategoryBadge extends StatelessWidget {
  final String? categorie;
  final bool large;

  const CategoryBadge({super.key, this.categorie, this.large = false});

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

  @override
  Widget build(BuildContext context) {
    final cat   = categorie ?? 'Autre';
    final color = AppColors.categoryColors[cat] ?? AppColors.categoryColors['Autre']!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical:   large ? 6  : 4,
      ),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(cat), size: large ? 16 : 12, color: color),
          const SizedBox(width: 4),
          Text(
            cat,
            style: TextStyle(
              color:      color,
              fontSize:   large ? 13 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}