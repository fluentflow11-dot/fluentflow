import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../core/auth_providers.dart';
import '../../core/analytics.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _loading = false;
  String? _emailProviderHint; // 'google.com' or 'password'

  Future<void> _checkEmailProvider(String email) async {
    final auth = ref.read(authServiceProvider);
    try {
      final methods = await auth.getSignInMethodsForEmail(email);
      if (methods.contains('google.com') && !methods.contains('password')) {
        setState(() => _emailProviderHint = 'google.com');
      } else if (methods.contains('password')) {
        setState(() => _emailProviderHint = 'password');
      } else {
        setState(() => _emailProviderHint = null);
      }
    } catch (_) {
      // ignore best-effort
    }
  }

  Future<void> _handleSubmit() async {
    final auth = ref.read(authServiceProvider);
    final analytics = ref.read(appAnalyticsProvider);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isLogin) {
        await auth.signInWithEmail(email, password);
        await analytics.logLogin(method: 'password');
      } else {
        try {
          await auth.registerWithEmail(email, password);
          await analytics.logSignUp(method: 'password');
        } on Object catch (e) {
          final str = e.toString();
          if (str.contains('email-already-in-use')) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Email already in use. If this is your account, you can reset your password.'),
                action: SnackBarAction(
                  label: 'Reset',
                  onPressed: () async {
                    await ref.read(authServiceProvider).sendPasswordReset(email);
                  },
                ),
              ),
            );
            return;
          }
          rethrow;
        }
      }
      if (mounted) Navigator.of(context).maybePop();
    } on Object catch (e) {
      // Best-effort error analytics
      final msg = e.toString();
      final code = msg.contains(']') ? msg.substring(msg.indexOf(']') + 1) : msg;
      try { await ref.read(appAnalyticsProvider).logAuthError(code: code, message: msg); } catch (_) {}
      if (!mounted) return;
      String message = 'Auth error: $e';
      if (e is Exception) {
        final str = e.toString();
        if (str.contains('wrong-password')) message = 'Incorrect password. You can reset it from the link in the snackbar.';
        if (str.contains('user-not-found')) message = 'No account found for this email.';
        if (str.contains('email-already-in-use')) message = 'Email already in use.';
        if (str.contains('weak-password')) message = 'Password is too weak.';
      }
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text(message)));
      // Offer password reset shortcut on wrong-password
      if (message.startsWith('Incorrect password')) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Send password reset email?'),
            action: SnackBarAction(
              label: 'Send',
              onPressed: () async {
                await ref.read(authServiceProvider).sendPasswordReset(_emailController.text.trim());
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleAnonymous() async {
    final auth = ref.read(authServiceProvider);
    final analytics = ref.read(appAnalyticsProvider);
    setState(() => _loading = true);
    try {
      await auth.signInAnonymously();
      await analytics.logLogin(method: 'anonymous');
      if (mounted) Navigator.of(context).maybePop();
    } on Object catch (e) {
      if (!mounted) return;
      String message = 'Anon error: $e';
      if (e is Exception) {
        final str = e.toString();
        if (str.contains('operation-not-allowed') || str.contains('admin-restricted-operation')) {
          message = 'Guest sign-in is disabled. Enable the Anonymous provider in Firebase → Authentication → Sign-in method.';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_isLogin ? 'Welcome back' : 'Create account', style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: context.spacing.lg),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) {
                    final value = v.trim();
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (emailRegex.hasMatch(value)) {
                      _checkEmailProvider(value);
                    }
                  },
                  validator: (value) {
                    final v = (value ?? '').trim();
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (v.isEmpty) return 'Email is required';
                    if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: context.spacing.md),
                if (!(_emailProviderHint == 'google.com' && _isLogin == false))
                  TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    final v = value ?? '';
                    if (v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Use at least 8 characters';
                    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Include at least one number';
                    return null;
                  },
                ),
                if (!_isLogin) ...[
                  SizedBox(height: context.spacing.md),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (value) {
                      if (_isLogin) return null;
                      final v = value ?? '';
                      if (v.isEmpty) return 'Confirm your password';
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                ],
                if (_emailProviderHint == 'google.com' && _isLogin)
                  Padding(
                    padding: EdgeInsets.only(top: context.spacing.sm),
                    child: Text(
                      'This email uses Google sign‑in. Use the Google button below.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                SizedBox(height: context.spacing.lg),
                FilledButton(
                  onPressed: _loading ? null : _handleSubmit,
                  child: Text(_isLogin ? 'Sign in' : 'Create account'),
                ),
                SizedBox(height: context.spacing.sm),
                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              // Synchronous push avoids async context warning
                              context.pushNamed('forgot-password');
                            },
                      child: const Text('Forgot password?'),
                    ),
                  ),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() {
                            _isLogin = !_isLogin;
                            // Clear confirm field when toggling modes
                            _confirmPasswordController.clear();
                          }),
                  child: Text(_isLogin ? 'Need an account? Sign up' : 'Have an account? Sign in'),
                ),
                SizedBox(height: context.spacing.lg),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _handleAnonymous,
                  icon: const Icon(Icons.bolt),
                  label: const Text('Continue as guest'),
                ),
              SizedBox(height: context.spacing.md),
              OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () async {
                        final auth = ref.read(authServiceProvider);
                        final analytics = ref.read(appAnalyticsProvider);
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _loading = true);
                        try {
                          await auth.signInWithGoogle();
                          await analytics.logLogin(method: 'google');
                          if (!mounted) return;
                          navigator.maybePop();
                        } catch (e) {
                          try { await analytics.logAuthError(code: 'google_sign_in', message: e.toString()); } catch (_) {}
                          if (!mounted) return;
                          messenger.showSnackBar(SnackBar(content: Text('Google sign-in error: $e')));
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Continue with Google'),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}


