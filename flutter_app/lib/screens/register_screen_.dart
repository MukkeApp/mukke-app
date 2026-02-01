// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthFormMode { signup, login }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.initialMode = AuthFormMode.signup});

  final AuthFormMode initialMode;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _busy = false;
  String? _error;
  late AuthFormMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      if (_mode == AuthFormMode.signup) {
        await auth.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _pwCtrl.text,
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _pwCtrl.text,
        );
      }
      // AuthGate reagiert auf den Stream und schickt ins Home
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapFirebaseError(e, _mode));
    } catch (e) {
      setState(() => _error = 'Unerwarteter Fehler: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mapFirebaseError(FirebaseAuthException e, AuthFormMode mode) {
    switch (e.code) {
      case 'email-already-in-use':
      // Tipp: Direkt Login-Modus anbieten
        return 'Diese E-Mail ist bereits registriert. Bitte melde dich an.';
      case 'invalid-email':
        return 'Die E-Mail-Adresse ist ungültig.';
      case 'weak-password':
        return 'Das Passwort ist zu schwach (mind. 6 Zeichen).';
      case 'user-not-found':
        return mode == AuthFormMode.login
            ? 'Kein Konto mit dieser E-Mail gefunden.'
            : 'Benutzer nicht gefunden.';
      case 'wrong-password':
        return 'Falsches Passwort.';
      case 'too-many-requests':
        return 'Zu viele Versuche. Bitte später erneut versuchen.';
      default:
        return 'Fehler (${e.code}): ${e.message ?? 'Unbekannt'}';
    }
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthFormMode.signup ? AuthFormMode.login : AuthFormMode.signup;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSignup = _mode == AuthFormMode.signup;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                color: const Color(0xFF2D2D2D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSignup ? 'Konto erstellen' : 'Anmelden',
                          style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_error != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x33F44336),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: _dec('E-Mail'),
                          style: const TextStyle(color: Colors.white),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Bitte E-Mail eingeben';
                            if (!v.contains('@')) return 'Bitte gültige E-Mail eingeben';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _pwCtrl,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: _dec('Passwort'),
                          style: const TextStyle(color: Colors.white),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Bitte Passwort eingeben';
                            if (v.length < 6) return 'Mindestens 6 Zeichen';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _busy ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00BFFF),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _busy
                                ? const SizedBox(
                              width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : Text(isSignup ? 'Registrieren' : 'Anmelden',
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _busy ? null : _toggleMode,
                          child: Text(
                            isSignup
                                ? 'Bereits angemeldet? Hier einloggen'
                                : 'Noch kein Konto? Jetzt registrieren',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        if (!isSignup) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () async {
                              // Passwort zurücksetzen
                              final email = _emailCtrl.text.trim();
                              if (email.isEmpty || !email.contains('@')) {
                                setState(() => _error = 'Bitte eine gültige E-Mail für den Reset eingeben.');
                                return;
                              }
                              try {
                                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Passwort-Reset-E-Mail gesendet.')),
                                  );
                                }
                              } on FirebaseAuthException catch (e) {
                                setState(() => _error = _mapFirebaseError(e, _mode));
                              }
                            },
                            child: const Text('Passwort vergessen?', style: TextStyle(color: Colors.white54)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF252525),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00BFFF)),
      ),
    );
  }
}
