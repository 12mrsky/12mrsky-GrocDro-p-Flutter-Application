import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          /// HEADER WITH USER + ADDRESS
          Container(
             backgroundColor: theme.cardColor,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? "Guest",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 10),

                  /// ADDRESS PICKER
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/map_picker');
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Select delivery address",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Icon(Icons.edit, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _tile(context, Icons.category, "Shop By Category", '/'),

          _divider(),

          _tile(context, Icons.shopping_bag_outlined, "My Orders", '/orders'),
          _tile(context, Icons.location_on_outlined, "Saved Address", '/address'),
          _tile(context, Icons.payment_outlined, "Payments & Refunds", '/payments'),

          _divider(),

          _tile(context, Icons.help_outline, "Help Center", '/help'),
          _tile(context, Icons.question_answer_outlined, "FAQ", '/faq'),
          _tile(context, Icons.info_outline, "About Us", '/about'),

          const Spacer(),

          /// LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),

          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text("Version 1.0.0"),
          )
        ],
      ),
    );
  }

  /// ACTIVE HIGHLIGHT
  Widget _tile(
      BuildContext context, IconData icon, String title, String route) {
    final isActive = currentRoute == route;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: isActive ? Colors.green.withOpacity(.1) : null,
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.green : null),
        title: Text(title,
            style: TextStyle(
                color: isActive ? Colors.green : null,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.pop(context);
          if (!isActive) Navigator.pushNamed(context, route);
        },
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);
}