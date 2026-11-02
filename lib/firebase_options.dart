import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Run `flutterfire configure --project=<your-new-project-id>` to update
/// this file automatically with your new Firebase project credentials.
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyForWeb12345',
    appId: '1:579219635931:web:aluincidentappweb',
    messagingSenderId: '579219635931',
    projectId: 'alu-campuscare-demo',
    authDomain: 'alu-campuscare-demo.firebaseapp.com',
    storageBucket: 'alu-campuscare-demo.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyForAndroid12',
    appId: '1:579219635931:android:aluincidentappandroid',
    messagingSenderId: '579219635931',
    projectId: 'alu-campuscare-demo',
    storageBucket: 'alu-campuscare-demo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyForIOS12345',
    appId: '1:579219635931:ios:aluincidentappios',
    messagingSenderId: '579219635931',
    projectId: 'alu-campuscare-demo',
    storageBucket: 'alu-campuscare-demo.firebasestorage.app',
    iosBundleId: 'com.alu.campuscare.campusCare',
  );
}
