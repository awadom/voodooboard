import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  /// Links a silently signed-in Google account to Firebase Auth
  static Future<void> linkSilentAccount(GoogleSignInAccount account) async {
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  /// Google Sign-In with popup fallback to redirect
  static Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      try {
        final cred = await _auth.signInWithPopup(provider);
        return cred.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'auth/popup-blocked' ||
            e.code == 'auth/popup-closed-by-user' ||
            e.code == 'auth/web-storage-unsupported') {
          await _auth.signInWithRedirect(provider);
          return null; // Handle after redirect
        }
        rethrow;
      }
    } else {
      // Mobile (Android/iOS) flow
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
  static Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
    await _auth.signOut();
  }
}
