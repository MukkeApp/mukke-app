import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mukke_app/services/auth_service.dart';

enum AuthFormMode { login, signup }

class RegisterScreen extends StatefulWidget {
  final AuthFormMode initialMode;

  const RegisterScreen({
    super.key,
    this.initialMode = AuthFormMode.login,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialMode == AuthFormMode.login;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthService>();

    try {
      if (_isLogin) {
        await auth.signInWithEmailPassword(
          email: _emailCtrl.text,
          password: _pwCtrl.text,
        );
      } else {
        await auth.signUpWithEmailPassword(
          email: _emailCtrl.text,
          password: _pwCtrl.text,
          displayName: _nameCtrl.text,
        );
      }
      // AuthGate schaltet automatisch um (authStateChanges)
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unbekannter Fehler.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib deine E-Mail ein.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthService>().sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwort-Reset E-Mail wurde gesendet.')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Bitte E-Mail eingeben.';
    if (!v.contains('@')) return 'Bitte gültige E-Mail eingeben.';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Bitte Passwort eingeben.';
    if (v.length < 6) return 'Mindestens 6 Zeichen.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Anmelden' : 'Registrieren'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isLogin)
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name (optional)',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pwCtrl,
                    decoration: const InputDecoration(labelText: 'Passwort'),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: _validatePassword,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isLogin ? 'Login' : 'Account erstellen'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLogin)
                    TextButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      child: const Text('Passwort vergessen?'),
                    ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                    child: Text(
                      _isLogin
                          ? 'Noch keinen Account? Registrieren'
                          : 'Schon einen Account? Anmelden',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
