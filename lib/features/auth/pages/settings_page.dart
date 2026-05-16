import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Profil
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius:          30,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    user?.nom.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize:   24,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.nom ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:   16,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color:    Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Langue
          Container(
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.language, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        tr('language'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize:   15,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bouton Français
                _LangTile(
                  flag:     '🇫🇷',
                  label:    'Français',
                  locale:   const Locale('fr'),
                  isActive: context.locale == const Locale('fr'),
                ),
                const Divider(height: 1, indent: 16),
                // Bouton Anglais
                _LangTile(
                  flag:     '🇬🇧',
                  label:    'English',
                  locale:   const Locale('en'),
                  isActive: context.locale == const Locale('en'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Logout
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon:  const Icon(Icons.logout),
              label: Text(
                tr('logout'),
                style: const TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String  flag;
  final String  label;
  final Locale  locale;
  final bool    isActive;

  const _LangTile({
    required this.flag,
    required this.label,
    required this.locale,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title:   Text(label),
      trailing: isActive
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () => context.setLocale(locale),
    );
  }
}