import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_tokens.dart';
import '../../core/auth_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;

  Future<void> _handleSubmit() async {
    final auth = ref.read(authServiceProvider);
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isLogin) {
        await auth.signInWithEmail(email, password);
      } else {
        await auth.registerWithEmail(email, password);
      }
      if (mounted) Navigator.of(context).maybePop();
    } on Object catch (e) {
      if (!mounted) return;
      String message = 'Auth error: $e';
      if (e is Exception) {
        final str = e.toString();
        if (str.contains('wrong-password')) message = 'Incorrect password.';
        if (str.contains('user-not-found')) message = 'No account found for this email.';
        if (str.contains('email-already-in-use')) message = 'Email already in use.';
        if (str.contains('weak-password')) message = 'Password is too weak.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleAnonymous() async {
    final auth = ref.read(authServiceProvider);
    setState(() => _loading = true);
    try {
      await auth.signInAnonymously();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_isLogin ? 'Welcome back' : 'Create account', style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: context.spacing.lg),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: context.spacing.md),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: context.spacing.lg),
              FilledButton(
                onPressed: _loading ? null : _handleSubmit,
                child: Text(_isLogin ? 'Sign in' : 'Create account'),
              ),
              SizedBox(height: context.spacing.sm),
              TextButton(
                onPressed: _loading ? null : () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'Need an account? Sign up' : 'Have an account? Sign in'),
              ),
              SizedBox(height: context.spacing.lg),
              OutlinedButton.icon(
                onPressed: _loading ? null : _handleAnonymous,
                icon: const Icon(Icons.bolt),
                label: const Text('Continue as guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


