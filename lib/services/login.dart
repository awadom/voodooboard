import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isRegistering = false;
  bool _loading = false;
  bool _redirectLoading = false; // Loading while waiting for redirect result
  String? _error;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = AuthService.currentUser;
    if (kIsWeb) {
      _handleRedirectResult();
    }
  }

  Future<void> _handleRedirectResult() async {
    setState(() {
      _redirectLoading = true;
      _error = null;
    });

    try {
      final user = await AuthService.getRedirectResult();
      if (user != null) {
        setState(() {
          _user = user;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error retrieving redirect result: $e';
      });
    } finally {
      setState(() {
        _redirectLoading = false;
      });
    }
  }

  Future<void> _handleEmailAuth(BuildContext context) async {
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
      setState(() {
        _user = _auth.currentUser;
      });
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // signInWithGoogle on web triggers redirect, so user will be null immediately
      final user = await AuthService.signInWithGoogle();
      if (user != null) {
        setState(() {
          _user = user;
        });
        Navigator.pop(context);
      }
      // else: redirect will reload page and _handleRedirectResult will update state
    } catch (e) {
      setState(() => _error = e.toString());
      setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _loading = true);
    await AuthService.signOut();
    setState(() {
      _loading = false;
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_redirectLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_user == null) ...[
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
                    onChanged: (val) {
                      setState(() => _isRegistering = val ?? false);
                    },
                  ),
                  const Text("Register new account"),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_user == null) ...[
              ElevatedButton(
                onPressed: () => _handleEmailAuth(context),
                child: Text(_isRegistering ? "Register" : "Sign in with Email"),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _signInWithGoogle(context),
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
              ),
            ] else ...[
              Text("Signed in as: ${_user!.email ?? _user!.displayName}"),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
