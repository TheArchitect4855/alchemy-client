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
      return web;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDLTQ0OBljuDuPSHsnbAgv11O3LWqzOP-w',
    appId: '1:807536954475:web:1eee72f33200d98a6e752e',
    messagingSenderId: '807536954475',
    projectId: 'alchemy-17ab2',
    authDomain: 'alchemy-17ab2.firebaseapp.com',
    storageBucket: 'alchemy-17ab2.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAFKLAcESr7cLqImov-802BwrsF4Sbf9Yg',
    appId: '1:807536954475:android:1e7563684a8f4b6d6e752e',
    messagingSenderId: '807536954475',
    projectId: 'alchemy-17ab2',
    storageBucket: 'alchemy-17ab2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmJENdBxQcMF-AiDJKH_a4Noz7P_yViV8',
    appId: '1:807536954475:ios:b6b75e32b7976d096e752e',
    messagingSenderId: '807536954475',
    projectId: 'alchemy-17ab2',
    storageBucket: 'alchemy-17ab2.appspot.com',
    iosClientId: '807536954475-l6e4j1919iv2a1l5ndkmogpr2fs6a65v.apps.googleusercontent.com',
    iosBundleId: 'app.usealchemy.alchemy',
  );
}