import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'app_root.dart';

// Providers
import 'domain/providers/auth_provider.dart';
import 'domain/providers/cart_provider.dart';
import 'domain/providers/order_provider.dart';

// Theme
import 'core/app_colors.dart';
import 'core/theme_provider.dart';

// Screens
import 'screens/dashboard/cart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GrocDropApp());
}

class GrocDropApp extends StatelessWidget {
  const GrocDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'GrocDrop',
            themeMode: theme.themeMode,

            // 🌞 LIGHT THEME
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColors.background,
              primaryColor: AppColors.primary,
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                secondary: AppColors.accent,
                background: AppColors.background,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textDark,
                elevation: 0,
              ),
              cardColor: AppColors.card,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: AppColors.textDark),
                bodyMedium: TextStyle(color: AppColors.textDark),
                bodySmall: TextStyle(color: AppColors.textGrey),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              dividerColor: AppColors.border,
            ),

            // 🌙 DARK THEME
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              primaryColor: AppColors.primary,
              colorScheme: ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.accent,
                background: const Color(0xFF121212),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF121212),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              cardColor: const Color(0xFF1E1E1E),
            ),

            // 🔗 ROUTES
            routes: {
              '/cart': (context) => const CartScreen(),
            },

            // 🚀 ROOT
            home: const AppRoot(),
          );
        },
      ),
    );
  }
}
