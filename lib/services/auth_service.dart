import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Conditionally import platform_utils to detect mobile web properly
import '../utils/platform_utils_stub.dart'
    if (dart.library.js_interop) '../utils/platform_utils_web.dart';

//
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();

      try {
        // On desktop web or non-mobile web, try popup
        if (!isMobileBrowser()) {
          final result = await _auth.signInWithPopup(googleProvider);
          return result.user;
        } else {
          // On mobile web, fallback to redirect sign in
          await _auth.signInWithRedirect(googleProvider);
          return null; // Redirect will reload and handle auth later
        }
      } catch (e) {
        // If popup fails for any reason, fallback to redirect
        await _auth.signInWithRedirect(googleProvider);
        return null;
      }
    } else {
      // Native mobile platforms: Android and iOS
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '547078088322-9mgcp3b5kdtcedbtg130c56vlocatsjg.apps.googleusercontent.com', // Set your iOS and Android client IDs here if needed
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

  /// Call this in `main()` after `Firebase.initializeApp()` to handle web redirect
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
