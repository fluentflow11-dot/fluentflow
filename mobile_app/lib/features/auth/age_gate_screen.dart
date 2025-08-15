import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_tokens.dart';
import '../../core/hive_init.dart';
import 'package:go_router/go_router.dart';

class AgeGateScreen extends ConsumerStatefulWidget {
  const AgeGateScreen({super.key});

  @override
  ConsumerState<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends ConsumerState<AgeGateScreen> {
  DateTime? _birthdate;
  bool _saving = false;

  int _calculateAge(DateTime birthdate) {
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    final hadBirthdayThisYear = (now.month > birthdate.month) ||
        (now.month == birthdate.month && now.day >= birthdate.day);
    if (!hadBirthdayThisYear) age -= 1;
    return age;
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 120, 1, 1);
    final initial = _birthdate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthdate = picked);
    }
  }

  Future<void> _continue() async {
    if (_birthdate == null) return;
    final age = _calculateAge(_birthdate!);
    if (age < 13) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be 13+ or have parental consent.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final cache = ref.read(appCacheProvider);
      await cache.setPref('age_gate_verified', true);
      await cache.setPref('birthdate_millis', _birthdate!.millisecondsSinceEpoch);
      if (!mounted) return;
      // Move to onboarding intro explicitly to avoid redirect loops
      context.go('/onboarding-intro');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Age verification')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Please confirm your birthdate to continue',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: context.spacing.lg),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickBirthdate,
                icon: const Icon(Icons.cake_outlined),
                label: Text(
                  _birthdate == null
                      ? 'Select birthdate'
                      : '${_birthdate!.year}-${_birthdate!.month.toString().padLeft(2, '0')}-${_birthdate!.day.toString().padLeft(2, '0')}',
                ),
              ),
              SizedBox(height: context.spacing.md),
              FilledButton(
                onPressed: _saving || _birthdate == null ? null : _continue,
                child: _saving ? const CircularProgressIndicator() : const Text('Continue'),
              ),
              SizedBox(height: context.spacing.lg),
              const Text(
                'By continuing, you confirm you are at least 13 years old. If under 13, a parent or guardian must provide consent (COPPA).',
              ),
            ],
          ),
        ),
      ),
    );
  }
}


