import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

class AuthService {
  AuthService(this._auth);
  final FirebaseAuth _auth;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<UserCredential> signInAnonymously() async {
    return _auth.signInAnonymously();
  }

  Future<UserCredential> registerWithEmail(String email, String password) async {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<List<String>> getSignInMethodsForEmail(String email) async {
    // Support API name across versions using dynamic to avoid static analyzer errors
    final dynamic dynAuth = _auth;
    try {
      final dynamic methods = await (dynAuth.fetchSignInMethods(email) as Future);
      return List<String>.from(methods as List);
    } catch (_) {
      try {
        final dynamic methods = await (dynAuth.fetchSignInMethodsForEmail(email) as Future);
        return List<String>.from(methods as List);
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> linkPasswordToCurrentUser(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No signed-in user with email');
    }
    final cred = EmailAuthProvider.credential(email: user.email!, password: password);
    await user.linkWithCredential(cred);
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final account = await googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google sign-in aborted');
    }
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // Also sign out the Google session so the account chooser appears next time
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // ignore best-effort
    }
    // Best-effort clear cached tokens
    try {
      await _secureStorage.delete(key: 'ff_id_token');
      await _secureStorage.delete(key: 'ff_refresh_token');
    } catch (_) {}
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthService(auth);
});

/// Session manager: persists ID token and listens for token refreshes.
class AuthSessionManager {
  AuthSessionManager(this._auth);
  final FirebaseAuth _auth;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Stream<String?> idTokenStream() => _auth.idTokenChanges().asyncMap((user) async {
        if (user == null) {
          await _secureStorage.delete(key: 'ff_id_token');
          return null;
        }
        final token = await user.getIdToken();
        try {
          await _secureStorage.write(key: 'ff_id_token', value: token);
        } catch (_) {}
        return token;
      });

  Future<String?> readCachedIdToken() async {
    try {
      return _secureStorage.read(key: 'ff_id_token');
    } catch (_) {
      return null;
    }
  }
}

final authSessionManagerProvider = Provider<AuthSessionManager>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthSessionManager(auth);
});

/// Listens to idTokenChanges and keeps a subscription alive for app lifetime.
final authTokenListenerProvider = Provider<void>((ref) {
  final manager = ref.read(authSessionManagerProvider);
  final subscription = manager.idTokenStream().listen((_) {});
  ref.onDispose(() => subscription.cancel());
});


