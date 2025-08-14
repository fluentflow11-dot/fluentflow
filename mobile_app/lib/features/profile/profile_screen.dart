import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_service.dart';
import 'user_profile.dart';
import '../../core/auth_providers.dart';
import '../../core/design_tokens.dart';

class ProfileScreen extends ConsumerStatefulWidget {
	const ProfileScreen({super.key});

	@override
	ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
	final _nameCtrl = TextEditingController();
	DateTime? _birthdate;
	File? _avatar;
	final _formKey = GlobalKey<FormState>();
	bool _saving = false;
	final _setPasswordCtrl = TextEditingController();
	bool _showSetPassword = false;

	Future<void> _pickBirthdate() async {
		final now = DateTime.now();
		final picked = await showDatePicker(
			context: context,
			initialDate: DateTime(now.year - 20, now.month, now.day),
			firstDate: DateTime(1900),
			lastDate: now,
		);
		if (picked != null) setState(() => _birthdate = picked);
	}

	Future<void> _pickAvatar() async {
		final picker = ImagePicker();
		final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
		if (x != null) setState(() => _avatar = File(x.path));
	}

	Future<void> _save() async {
		if (!_formKey.currentState!.validate() || _birthdate == null) return;
		setState(() => _saving = true);
		try {
			final service = ref.read(profileServiceProvider);
			final user = FirebaseAuth.instance.currentUser;
			if (user == null) throw Exception('Not signed in');
			String? photoUrl;
			if (_avatar != null) {
				photoUrl = await service.uploadAvatar(user.uid, _avatar!);
			}
			final profile = UserProfile(
				uid: user.uid,
				name: _nameCtrl.text.trim(),
				birthdateMillis: _birthdate!.toUtc().millisecondsSinceEpoch,
				photoUrl: photoUrl,
			);
			await service.saveProfile(profile);

			// Optionally link a password if requested
			if (_showSetPassword && _setPasswordCtrl.text.trim().isNotEmpty) {
				try {
					await ref.read(authServiceProvider).linkPasswordToCurrentUser(_setPasswordCtrl.text.trim());
				} catch (e) {
					if (mounted) {
						ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Set password failed: $e')));
					}
				}
			}
			if (!mounted) return;
			Navigator.of(context).maybePop();
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save error: $e')));
		} finally {
			if (mounted) setState(() => _saving = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Create profile')),
			body: SafeArea(
				child: SingleChildScrollView(
					padding: EdgeInsets.all(context.spacing.lg),
					child: Form(
						key: _formKey,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								Center(
									child: GestureDetector(
										onTap: _saving ? null : _pickAvatar,
										child: CircleAvatar(
											radius: 48,
											backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
											child: _avatar == null ? const Icon(Icons.person, size: 48) : null,
										),
									),
								),
								SizedBox(height: context.spacing.lg),
								TextFormField(
									controller: _nameCtrl,
									decoration: const InputDecoration(labelText: 'Name'),
									validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
								),
								SizedBox(height: context.spacing.md),
								Row(
									children: [
										Expanded(
											child: Text(_birthdate == null ? 'Birthdate: not set' : 'Birthdate: ${_birthdate!.toLocal().toIso8601String().split('T').first}'),
										),
										FilledButton(
											onPressed: _saving ? null : _pickBirthdate,
											child: const Text('Pick date'),
										),
									],
								),
							SizedBox(height: context.spacing.lg),
							SwitchListTile.adaptive(
								title: const Text('Set a password for email sign-in'),
								value: _showSetPassword,
								onChanged: _saving ? null : (v) => setState(() => _showSetPassword = v),
							),
							if (_showSetPassword) ...[
								TextFormField(
									controller: _setPasswordCtrl,
									decoration: const InputDecoration(labelText: 'New password'),
									obscureText: true,
									validator: (v) {
										final s = v ?? '';
										if (!_showSetPassword) return null;
										if (s.length < 8) return 'Use at least 8 characters';
										if (!RegExp(r'[0-9]').hasMatch(s)) return 'Include at least one number';
										return null;
									},
								),
								SizedBox(height: context.spacing.md),
							],
							FilledButton(
									onPressed: _saving ? null : _save,
									child: const Text('Save profile'),
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
		_nameCtrl.dispose();
		super.dispose();
	}
}


