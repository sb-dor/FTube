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
        return macos;
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
    apiKey: 'AIzaSyBWPtKfwzHeSzpUqnuQdPlZpheCyuz8RuY',
    appId: '1:583795295936:web:b6cf82f39ddc0c2ee50f25',
    messagingSenderId: '583795295936',
    projectId: 'ftube-bd64a',
    authDomain: 'ftube-bd64a.firebaseapp.com',
    storageBucket: 'ftube-bd64a.appspot.com',
    measurementId: 'G-N8GEZ7N4V7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8QXVDde7X2g5q8hElo-_yzyIDFtUZz-Y',
    appId: '1:583795295936:android:957ef652d416ac1be50f25',
    messagingSenderId: '583795295936',
    projectId: 'ftube-bd64a',
    storageBucket: 'ftube-bd64a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAdlU4gKhoA30sYT4V956bnFZvmyZ85QMQ',
    appId: '1:583795295936:ios:c1826c9d75a27a2ee50f25',
    messagingSenderId: '583795295936',
    projectId: 'ftube-bd64a',
    storageBucket: 'ftube-bd64a.appspot.com',
    iosBundleId: 'com.example.youtube',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAdlU4gKhoA30sYT4V956bnFZvmyZ85QMQ',
    appId: '1:583795295936:ios:72cf0a6b71830968e50f25',
    messagingSenderId: '583795295936',
    projectId: 'ftube-bd64a',
    storageBucket: 'ftube-bd64a.appspot.com',
    iosBundleId: 'com.example.youtube.RunnerTests',
  );
}
