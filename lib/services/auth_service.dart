import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      // Always do redirect on web for consistency
      final googleProvider = GoogleAuthProvider();

      await _auth.signInWithRedirect(googleProvider);
      return null; // User will return on app reload after redirect
    } else {
      // Native platforms (Android/iOS)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    }
  }

  static Future<User?> getRedirectResult() async {
    if (kIsWeb) {
      try {
        final result = await _auth.getRedirectResult();
        return result.user;
      } catch (e) {
        print("Redirect result error: $e");
        return null;
      }
    }
    return null;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        print('Error signing out from Google: $e');
      }
    }
  }
}
