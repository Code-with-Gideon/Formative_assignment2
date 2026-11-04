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
    apiKey: 'AIzaSyAocJsdqE6ls93XIo2jsgjlxQue7p9j45Y',
    appId: '1:166386448892:web:81be7c1ec13d3023775a79',
    messagingSenderId: '166386448892',
    projectId: 'formative-assignment2',
    authDomain: 'formative-assignment2.firebaseapp.com',
    storageBucket: 'formative-assignment2.firebasestorage.app',
    measurementId: 'G-YS3GT6G8MJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsZ1RTOYhQkrstzCcHubFrvBiifsPLac4',
    appId: '1:166386448892:android:6236368f5aae9bbf775a79',
    messagingSenderId: '166386448892',
    projectId: 'formative-assignment2',
    storageBucket: 'formative-assignment2.firebasestorage.app',
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
