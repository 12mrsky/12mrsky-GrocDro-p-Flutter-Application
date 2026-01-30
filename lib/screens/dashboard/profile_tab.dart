// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_colors.dart';
import '../../core/theme_provider.dart';
import 'app_drawer.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/profile'),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      body: ListView(
        children: [
          Container(
            color: Colors.green,
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, ${user?.displayName ?? "Guest"}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Raipur, Chhattisgarh",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                title: Text(user?.displayName ?? "GrocDrop User"),
                subtitle: Text(user?.email ?? ""),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(children: [
              _ProfileTile(
                icon: Icons.shopping_bag_outlined,
                title: "My Orders",
                onTap: () => Navigator.pushNamed(context, '/orders'),
              ),
              _Divider(),
              _ProfileTile(
                icon: Icons.location_on_outlined,
                title: "Saved Addresses",
                onTap: () => Navigator.pushNamed(context, '/address'),
              ),
              _Divider(),
              _ProfileTile(
                icon: Icons.payment_outlined,
                title: "Payments & Refunds",
                onTap: () => Navigator.pushNamed(context, '/payments'),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(children: [
              SwitchListTile(
                value: isDark,
                onChanged: (value) {
                  context.read<ThemeProvider>().toggleTheme(value);
                },
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text("Dark Mode"),
              ),
              const Divider(height: 1),
              _ProfileTile(
                icon: Icons.notifications_none,
                title: "Notifications",
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
              _Divider(),
              _ProfileTile(
                icon: Icons.security_outlined,
                title: "Privacy & Security",
                onTap: () => Navigator.pushNamed(context, '/privacy'),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(children: [
              _ProfileTile(
                icon: Icons.help_outline,
                title: "Help Center",
                onTap: () => Navigator.pushNamed(context, '/help'),
              ),
              _Divider(),
              _ProfileTile(
                icon: Icons.info_outline,
                title: "About GrocDrop",
                onTap: () => Navigator.pushNamed(context, '/about'),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamedAndRemoveUntil('/', (route) => false);
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
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

/// REUSABLE

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
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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