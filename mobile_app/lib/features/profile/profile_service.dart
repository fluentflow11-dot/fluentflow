import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile.dart';

class ProfileService {
	ProfileService(this._firestore, this._storage, this._auth);
	final FirebaseFirestore _firestore;
	final FirebaseStorage _storage;
	final FirebaseAuth _auth;

	Future<void> saveProfile(UserProfile profile) async {
		await _firestore.collection('users').doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
	}

	Future<String> uploadAvatar(String uid, File file) async {
		final ref = _storage.ref().child('avatars/$uid.jpg');
		await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
		return ref.getDownloadURL();
	}

	Stream<User?> authChanges() => _auth.authStateChanges();
}

final profileServiceProvider = Provider<ProfileService>((ref) {
	return ProfileService(FirebaseFirestore.instance, FirebaseStorage.instance, FirebaseAuth.instance);
});


