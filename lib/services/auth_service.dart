import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Link silently signed-in Google account to Firebase
  static Future<void> linkSilentAccount(GoogleSignInAccount account) async {
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      await _auth.currentUser?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Linking account failed: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Cross-platform Google Sign-In
  static Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();

      try {
        // Try popup first
        await _auth.signInWithPopup(provider);
      } on FirebaseAuthException catch (e) {
        print('Popup sign-in failed: ${e.code}');
        // Fallback to redirect if popup fails
        if (e.code == 'popup-blocked' ||
            e.code == 'popup-closed-by-user' ||
            e.code == 'web-context-cancelled') {
          await _auth.signInWithRedirect(provider);
        } else {
          rethrow;
        }
      }
    } else {
      // Mobile/native sign-in
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    }
  }

  /// Sign out from Firebase and Google (if mobile)
  static Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}
