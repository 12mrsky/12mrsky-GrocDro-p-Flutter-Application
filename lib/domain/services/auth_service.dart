import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reuse GoogleSignIn instance (IMPORTANT)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // ✅ EMAIL LOGIN
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ✅ EMAIL SIGNUP
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ✅ GOOGLE LOGIN (FORCE ACCOUNT CHOOSER)
Future<UserCredential> signInWithGoogle() async {
  // 🔥 IMPORTANT: clear previous session
  await _googleSignIn.signOut();

  final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

  if (googleUser == null) {
    throw FirebaseAuthException(
      code: 'SIGN_IN_CANCELLED',
      message: 'Google sign in cancelled by user',
    );
  }

  final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

  final OAuthCredential credential =
      GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  return await _auth.signInWithCredential(credential);
}

}