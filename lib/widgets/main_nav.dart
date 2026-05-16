import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartspend/features/auth/pages/settings_page.dart';
import '../core/constants/app_colors.dart';
import '../features/transactions/pages/transactions_page.dart';
import '../features/budget/pages/budget_page.dart';
import '../features/anomalies/pages/anomalies_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    TransactionsPage(),
    BudgetPage(),
    AnomaliesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset:     const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex:           _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type:                   BottomNavigationBarType.fixed,
          selectedItemColor:      AppColors.primary,
          unselectedItemColor:    Colors.grey[400],
          backgroundColor:        Colors.white,
          selectedFontSize:       12,
          unselectedFontSize:     11,
          items: [
            BottomNavigationBarItem(
              icon:  const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: tr('dashboard'),
            ),
            BottomNavigationBarItem(
              icon:  const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: tr('transactions'),
            ),
            BottomNavigationBarItem(
              icon:  const Icon(Icons.pie_chart_outline),
              activeIcon: const Icon(Icons.pie_chart),
              label: tr('budget'),
            ),
            BottomNavigationBarItem(
              icon:  const Icon(Icons.warning_amber_outlined),
              activeIcon: const Icon(Icons.warning_amber),
              label: tr('anomalies'),
            ),
            BottomNavigationBarItem(
              icon:  const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: tr('settings'),
            ),
          ],
        ),
      ),
    );
  }
}