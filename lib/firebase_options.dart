import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChhbjiTiRtdZRj4v7MZupLc5AuXn0hiDI',
    appId: '1:640777137220:web:f38cdc0e26aaf27fe16011',
    messagingSenderId: '640777137220',
    projectId: 'selflog-2026',
    authDomain: 'selflog-2026.firebaseapp.com',
    storageBucket: 'selflog-2026.firebasestorage.app',
  );
}
