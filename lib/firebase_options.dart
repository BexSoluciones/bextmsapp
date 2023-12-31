// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAai1X4mDRQTENOY4n9c7y7mmhZl9K8sM8',
    appId: '1:334506920501:android:48b5d29d6e094bf1547f7c',
    messagingSenderId: '334506920501',
    projectId: 'entregas-322420',
    storageBucket: 'entregas-322420.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDIIZDQ6C7PL_GBHg--opXYRig6tBlhMpE',
    appId: '1:334506920501:ios:5a4385e355cff10c547f7c',
    messagingSenderId: '334506920501',
    projectId: 'entregas-322420',
    storageBucket: 'entregas-322420.appspot.com',
    androidClientId: '334506920501-g5qfe2jde4pfd74ba8el08fsncsensqk.apps.googleusercontent.com',
    iosClientId: '334506920501-5k9ol2rac4ars0js86k7fc3ort7gvf5o.apps.googleusercontent.com',
    iosBundleId: 'com.example.bexdeliveries',
  );
}
