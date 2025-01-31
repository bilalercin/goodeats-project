// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyANsar4-EPNkCGCbaRoLjENyIVIy1dFiMg',
    appId: '1:53889237195:web:21b213b88c90a58ced5b4e',
    messagingSenderId: '53889237195',
    projectId: 'goodeats-b213a',
    authDomain: 'goodeats-b213a.firebaseapp.com',
    storageBucket: 'goodeats-b213a.firebasestorage.app',
    measurementId: 'G-14CZQ24155',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2TOLgw1dHfBMD0d5Qt0zDOAF9jOKEas0',
    appId: '1:53889237195:android:2759cf5ed072a373ed5b4e',
    messagingSenderId: '53889237195',
    projectId: 'goodeats-b213a',
    storageBucket: 'goodeats-b213a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDplS9WJFxcOcyamr7cz1Q-KaVtbfWQrCk',
    appId: '1:53889237195:ios:61ec6cc50ce63c91ed5b4e',
    messagingSenderId: '53889237195',
    projectId: 'goodeats-b213a',
    storageBucket: 'goodeats-b213a.firebasestorage.app',
    androidClientId: '53889237195-pcruqkqmh8fa36gf3kefquu8qpbfsc11.apps.googleusercontent.com',
    iosClientId: '53889237195-2dkr72uhlcabed3jq90a1gon1uv5fjjv.apps.googleusercontent.com',
    iosBundleId: 'com.example.goodeats',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDplS9WJFxcOcyamr7cz1Q-KaVtbfWQrCk',
    appId: '1:53889237195:ios:61ec6cc50ce63c91ed5b4e',
    messagingSenderId: '53889237195',
    projectId: 'goodeats-b213a',
    storageBucket: 'goodeats-b213a.firebasestorage.app',
    androidClientId: '53889237195-pcruqkqmh8fa36gf3kefquu8qpbfsc11.apps.googleusercontent.com',
    iosClientId: '53889237195-2dkr72uhlcabed3jq90a1gon1uv5fjjv.apps.googleusercontent.com',
    iosBundleId: 'com.example.goodeats',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyANsar4-EPNkCGCbaRoLjENyIVIy1dFiMg',
    appId: '1:53889237195:web:e80109489266bf1ced5b4e',
    messagingSenderId: '53889237195',
    projectId: 'goodeats-b213a',
    authDomain: 'goodeats-b213a.firebaseapp.com',
    storageBucket: 'goodeats-b213a.firebasestorage.app',
    measurementId: 'G-0L6KFQ864Y',
  );

}