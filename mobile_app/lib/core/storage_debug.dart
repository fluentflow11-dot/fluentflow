import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageDebugService {
  StorageDebugService(this._storage);

  final FirebaseStorage _storage;

  Reference _helloRef(String uid) => _storage.ref('debug/$uid/hello.txt');

  Future<String> uploadHello(User user) async {
    final now = DateTime.now().toIso8601String();
    final content = 'Hello from FluentFlow at $now (uid=${user.uid})';
    final ref = _helloRef(user.uid);
    await ref.putString(
      content,
      metadata: SettableMetadata(contentType: 'text/plain'),
    );
    return ref.fullPath;
  }

  Future<String> downloadHello(User user) async {
    final ref = _helloRef(user.uid);
    final Uint8List? data = await ref.getData(1024 * 1024);
    if (data == null) return '';
    return String.fromCharCodes(data);
  }
}

final storageDebug = StorageDebugService(FirebaseStorage.instance);


