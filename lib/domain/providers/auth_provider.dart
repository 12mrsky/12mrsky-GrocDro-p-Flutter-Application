import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current Firebase user
  User? get user => _auth.currentUser;

  /// Logged-in status
  bool get isLoggedIn => _auth.currentUser != null;

  AuthProvider() {
    // 🔔 Listen to auth state changes
    _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  /// Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();  
  }
}
