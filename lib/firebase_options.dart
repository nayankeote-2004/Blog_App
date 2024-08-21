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
    apiKey: 'AIzaSyAaY8mfa21o7YhH84-1EXscYElWJz0VwqE',
    appId: '1:799262804369:web:347e8e0851d5eabbed7230',
    messagingSenderId: '799262804369',
    projectId: 'blog-app-cb524',
    authDomain: 'blog-app-cb524.firebaseapp.com',
    databaseURL: 'https://blog-app-cb524-default-rtdb.firebaseio.com',
    storageBucket: 'blog-app-cb524.appspot.com',
    measurementId: 'G-3RG8HJD1Q4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJKZp0L6Pcutgb-YjUIp-n8nP98B0UM8Q',
    appId: '1:799262804369:android:3cb21ecb42ddf942ed7230',
    messagingSenderId: '799262804369',
    projectId: 'blog-app-cb524',
    databaseURL: 'https://blog-app-cb524-default-rtdb.firebaseio.com',
    storageBucket: 'blog-app-cb524.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCC58k3jWhe72S8V-IPCFazpqloh378MU4',
    appId: '1:799262804369:ios:050bd776313c6cb3ed7230',
    messagingSenderId: '799262804369',
    projectId: 'blog-app-cb524',
    databaseURL: 'https://blog-app-cb524-default-rtdb.firebaseio.com',
    storageBucket: 'blog-app-cb524.appspot.com',
    iosBundleId: 'com.example.blogApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCC58k3jWhe72S8V-IPCFazpqloh378MU4',
    appId: '1:799262804369:ios:050bd776313c6cb3ed7230',
    messagingSenderId: '799262804369',
    projectId: 'blog-app-cb524',
    databaseURL: 'https://blog-app-cb524-default-rtdb.firebaseio.com',
    storageBucket: 'blog-app-cb524.appspot.com',
    iosBundleId: 'com.example.blogApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAaY8mfa21o7YhH84-1EXscYElWJz0VwqE',
    appId: '1:799262804369:web:4c9e65b5c4198398ed7230',
    messagingSenderId: '799262804369',
    projectId: 'blog-app-cb524',
    authDomain: 'blog-app-cb524.firebaseapp.com',
    databaseURL: 'https://blog-app-cb524-default-rtdb.firebaseio.com',
    storageBucket: 'blog-app-cb524.appspot.com',
    measurementId: 'G-30SSBH0R35',
  );
}
