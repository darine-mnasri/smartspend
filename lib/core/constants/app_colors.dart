import 'package:flutter/material.dart';

class AppColors {
  static const Color primary    = Color(0xFF1D9E75);
  static const Color secondary  = Color(0xFF378ADD);
  static const Color background = Color(0xFFF8F9FA);
  static const Color card       = Color(0xFFFFFFFF);
  static const Color error      = Color(0xFFD85A30);
  static const Color warning    = Color(0xFFEF9F27);

  static const Map<String, Color> categoryColors = {
    'Alimentation' : Color(0xFF1D9E75),
    'Transport'    : Color(0xFF378ADD),
    'Loisirs'      : Color(0xFF7F77DD),
    'Sante'        : Color(0xFFD85A30),
    'Shopping'     : Color(0xFFEF9F27),
    'Logement'     : Color(0xFF5F5E5A),
    'Autre'        : Color(0xFF9E9E9E),
  };
}