import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();

      try {
        // Try popup (desktop web)
        final result = await _auth.signInWithPopup(googleProvider);
        return result.user;
      } catch (e) {
        // Fallback to redirect (mobile web)
        await _auth.signInWithRedirect(googleProvider);
        return null; // Wait for redirect result on reload
      }
    } else {
      // Native mobile (Android/iOS)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? '547078088322-9mgcp3b5kdtcedbtg130c56vlocatsjg.apps.googleusercontent.com'
            : null,
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

  /// Call this in `main()` after `Firebase.initializeApp()` for web redirect
  static Future<void> handleRedirectResult() async {
    if (kIsWeb) {
      try {
        final result = await _auth.getRedirectResult();
        if (result.user != null) {
          print("Redirect sign-in success: ${result.user!.email}");
        }
      } catch (e) {
        print("Redirect result error: $e");
      }
    }
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
