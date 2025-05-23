// lib/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // for userAgent sniffing on web
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Links a silently signed-in Google account to Firebase Auth
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

  /// Google Sign-In with proper handling for web (popup/redirect) and iOS Safari
  static Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final ua = html.window.navigator.userAgent.toLowerCase();
      final isIosSafari = ua.contains('safari') &&
          (ua.contains('iphone') || ua.contains('ipad')) &&
          !ua.contains('crios') &&
          !ua.contains('fxios');

      if (isIosSafari) {
        // Safari mobile: use redirect
        await _auth.signInWithRedirect(provider);
      } else {
        try {
          await _auth.signInWithPopup(provider);
        } on FirebaseAuthException catch (e) {
          print('Popup sign-in failed: ${e.code}');
          if (e.code == 'popup-blocked' || e.code == 'popup-closed-by-user') {
            await _auth.signInWithRedirect(provider);
          } else {
            rethrow;
          }
        }
      }
    } else {
      // Android/iOS native
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

  /// Sign out from Firebase and Google (if on mobile)
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
