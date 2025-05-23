import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final String? currentMemberName;
  final VoidCallback? onLoginSuccess;

  const LoginPage({
    super.key,
    this.currentMemberName,
    this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isRegistering = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Complete redirect-based sign-in on mobile web
    FirebaseAuth.instance.getRedirectResult().then((result) {
      if (result.user != null) {
        widget.onLoginSuccess?.call();
      }
    }).catchError((error) {
      setState(() {
        _error = error.toString();
      });
    });

    // Listen for changes in auth state
    AuthService.authStateChanges.listen((user) {
      if (user != null) {
        widget.onLoginSuccess?.call();
      }
    });
  }

  Future<void> _handleEmailAuth() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isRegistering) {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.signInWithGoogle();
    } catch (e) {
      print('Google sign-in error: $e');
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: StreamBuilder<User?>(
        stream: AuthService.authStateChanges,
        builder: (context, snapshot) {
          final user = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user == null) ...[
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _isRegistering,
                        onChanged: (val) =>
                            setState(() => _isRegistering = val!),
                      ),
                      const Text("Register new account"),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (user == null) ...[
                  ElevatedButton(
                    onPressed: _handleEmailAuth,
                    child: Text(
                      _isRegistering ? "Register" : "Sign in with Email",
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text("Sign in with Google"),
                  ),
                ] else ...[
                  Text("Signed in as: ${user.email ?? user.displayName}"),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text("Sign Out"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
