// Generated from Firebase project phonoquest-7d1a7 (Android + iOS config files).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWyGKQl-oc3blRxTVankfaFr3fvw8R4vE',
    appId: '1:947246295715:android:9027b22c61547a684fed16',
    messagingSenderId: '947246295715',
    projectId: 'phonoquest-7d1a7',
    storageBucket: 'phonoquest-7d1a7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDzJ02XicfWvyuU4m_tHQ8w07dXu7pPyxQ',
    appId: '1:947246295715:ios:0de9c72276b01b8b4fed16',
    messagingSenderId: '947246295715',
    projectId: 'phonoquest-7d1a7',
    storageBucket: 'phonoquest-7d1a7.firebasestorage.app',
    iosBundleId: 'com.phonoquest',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWyGKQl-oc3blRxTVankfaFr3fvw8R4vE',
    appId: '1:947246295715:android:9027b22c61547a684fed16',
    messagingSenderId: '947246295715',
    projectId: 'phonoquest-7d1a7',
    storageBucket: 'phonoquest-7d1a7.firebasestorage.app',
  );

  static bool get isConfigured => true;
}
