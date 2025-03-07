// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBPbKt7DytYkw2LW1-VHHOFmYp13iFDKeI',
    appId: '1:583795295936:web:b6cf82f39ddc0c2ee50f25',
    messagingSenderId: '583795295936',
    projectId: 'ftube-bd64a',
    authDomain: 'ftube-bd64a.firebaseapp.com',
    storageBucket: 'ftube-bd64a.appspot.com',
    measurementId: 'G-N8GEZ7N4V7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPbKt7DytYkw2LW1-VHHOFmYp13iFDKeI',
    appId: '1:583795295936:android:0a9f0941ffef8c70e50f25',
    messagingSenderId: '583795295936',
    projectId: 'ftube-bd64a',
    storageBucket: 'ftube-bd64a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPbKt7DytYkw2LW1-VHHOFmYp13iFDKeI',
    appId: '1:583795295936:ios:1469c750136c1a16e50f25',
    messagingSenderId: '583795295936',
    projectId: 'ftube-bd64a',
    storageBucket: 'ftube-bd64a.appspot.com',
    androidClientId: '583795295936-l8h1v18hrqvf7j2ingpfsuc4inojmerf.apps.googleusercontent.com',
    iosClientId: '583795295936-3dfsq9r2ki146n1l4ibuv2jqut1s3i4j.apps.googleusercontent.com',
    iosBundleId: 'com.android.ftube',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBPbKt7DytYkw2LW1-VHHOFmYp13iFDKeI',
    appId: '1:583795295936:ios:72cf0a6b71830968e50f25',
    messagingSenderId: '583795295936',
    projectId: 'ftube-bd64a',
    storageBucket: 'ftube-bd64a.appspot.com',
    androidClientId: '583795295936-l8h1v18hrqvf7j2ingpfsuc4inojmerf.apps.googleusercontent.com',
    iosClientId: '583795295936-024o5pg971kijq676qet5vlafg3vflqu.apps.googleusercontent.com',
    iosBundleId: 'com.example.youtube.RunnerTests',
  );
}
