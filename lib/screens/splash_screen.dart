import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 241, 227), // cream bg
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.local_grocery_store,
              size: 80,
              color: Color.fromARGB(255, 55, 8, 55), // brand color
            ),
            SizedBox(height: 16),
            Text(
              "GrocDrop",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 55, 8, 55),
                letterSpacing: 1.3,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Fresh groceries, fast delivery",
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 90, 60, 90),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
