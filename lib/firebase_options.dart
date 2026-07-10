import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCAE5NEKsuG7zTQlxSt8Ti5GIauOOYgRCg',
    appId: '1:823623599963:android:74826be0986234b446bc7e',
    messagingSenderId: '823623599963',
    projectId: 'alu-grid',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAudMjxSX5M5G_XzyDXaoHHN9G-Mwnz5MU',
    appId: '1:823623599963:web:7430e1b62573487a46bc7e',
    messagingSenderId: '823623599963',
    projectId: 'alu-grid',
    authDomain: 'alu-grid.firebaseapp.com',
    storageBucket: 'alu-grid.firebasestorage.app',
  );
}