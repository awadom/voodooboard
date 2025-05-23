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
  static Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        // Finalize redirect sign-in if it was triggered
        final result = await _auth.getRedirectResult();
        if (result.user != null) {
          return result.user;
        }

        final provider = GoogleAuthProvider();
        final ua = html.window.navigator.userAgent.toLowerCase();
        final isIosSafari = ua.contains('safari') &&
            (ua.contains('iphone') || ua.contains('ipad')) &&
            !ua.contains('crios') &&
            !ua.contains('fxios');

        if (isIosSafari) {
          await _auth.signInWithRedirect(provider);
          return null;
        } else {
          final cred = await _auth.signInWithPopup(provider);
          return cred.user;
        }
      } on FirebaseAuthException catch (e) {
        print('Web Google Sign-In error: ${e.code} - ${e.message}');
        if (e.code == 'auth/popup-blocked' ||
            e.code == 'auth/popup-closed-by-user') {
          await _auth.signInWithRedirect(GoogleAuthProvider());
          return null;
        }
        rethrow;
      }
    } else {
      try {
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
      } on FirebaseAuthException catch (e) {
        print('Mobile Google Sign-In error: ${e.code} - ${e.message}');
        rethrow;
      }
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
