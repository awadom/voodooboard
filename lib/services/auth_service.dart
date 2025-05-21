// lib/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // for userAgent sniffing on web
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  /// Links a silently signed-in Google account to Firebase Auth
  static Future linkSilentAccount(GoogleSignInAccount account) async {
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  /// Google Sign-In with proper handling for web (popup/redirect) and iOS Safari
  static Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();

      // Detect iOS Safari (blocks pop-ups)
      final ua = html.window.navigator.userAgent.toLowerCase();
      final isIosSafari = ua.contains('safari') &&
          (ua.contains('iphone') || ua.contains('ipad')) &&
          !ua.contains('crios') &&
          !ua.contains('fxios');

      if (isIosSafari) {
        // Force redirect flow on iOS Safari
        await _auth.signInWithRedirect(provider);
        final result = await _auth.getRedirectResult();
        return result.user;
      } else {
        // Try popup first
        try {
          final cred = await _auth.signInWithPopup(provider);
          return cred.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'auth/popup-blocked' ||
              e.code == 'auth/popup-closed-by-user') {
            // Fallback to redirect
            await _auth.signInWithRedirect(provider);
            final result = await _auth.getRedirectResult();
            return result.user;
          }
          rethrow;
        }
      }
    } else {
      // Native mobile flow
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      return userCred.user;
    }
  }

  /// Sign out from Firebase and Google (if on mobile)
  static Future signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
    await _auth.signOut();
  }
}
