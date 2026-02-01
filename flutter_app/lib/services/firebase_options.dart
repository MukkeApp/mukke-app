import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Plattform wird nicht unterstützt.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDnEsxrd3u-8u-9vdKqDPoZThCJu1UWM7I',
    appId: '1:881155995571:web:0429af35a69e882648bdc6',
    messagingSenderId: '881155995571',
    projectId: 'mukkeapp',
    storageBucket: 'mukkeapp.appspot.com', // ✅ korrigiert
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'IOS_API_KEY_HIER_EINFÜGEN',
    appId: 'IOS_APP_ID_HIER_EINFÜGEN',
    messagingSenderId: '881155995571',
    projectId: 'mukkeapp',
    storageBucket: 'mukkeapp.appspot.com', // ✅ korrigiert
    iosClientId: 'IOS_CLIENT_ID_HIER_EINFÜGEN',
    iosBundleId: 'IOS_BUNDLE_ID_HIER_EINFÜGEN',
  );
}
