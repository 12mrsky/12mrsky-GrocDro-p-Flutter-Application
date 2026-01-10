// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_colors.dart';
import '../../core/theme_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 👤 PROFILE HEADER (AMAZON STYLE)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.accent,
                  child: const Icon(
                    Icons.person,
                    size: 34,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'GrocDrop User',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 📦 ORDERS & PAYMENTS
          _SectionCard(
            children: const [
              _ProfileTile(
                icon: Icons.shopping_bag_outlined,
                title: "My Orders",
              ),
              _Divider(),
              _ProfileTile(
                icon: Icons.location_on_outlined,
                title: "Saved Addresses",
              ),
              _Divider(),
              _ProfileTile(
                icon: Icons.payment_outlined,
                title: "Payments & Refunds",
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ⚙️ SETTINGS
          _SectionCard(
            children: [
              SwitchListTile(
                value: isDark,
                onChanged: (value) {
                  context
                      .read<ThemeProvider>()
                      .toggleTheme(value);
                },
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text("Dark Mode"),
              ),
              const Divider(height: 1),
              const _ProfileTile(
                icon: Icons.notifications_none,
                title: "Notifications",
              ),
              const _Divider(),
              const _ProfileTile(
                icon: Icons.security_outlined,
                title: "Privacy & Security",
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ❓ HELP
          _SectionCard(
            children: const [
              _ProfileTile(
                icon: Icons.help_outline,
                title: "Help Center",
              ),
              _Divider(),
              _ProfileTile(
                icon: Icons.info_outline,
                title: "About GrocDrop",
              ),
            ],
          ),

          const SizedBox(height: 32),

          /// 🚪 LOGOUT
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                }
              },
              icon: Icon(Icons.logout, color: primary),
              label: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// 🔹 REUSABLE WIDGETS
/// =====================

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileTile({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {}, // 🔒 UI only (logic unchanged)
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1);
  }
}
