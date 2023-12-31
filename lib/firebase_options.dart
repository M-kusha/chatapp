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
    apiKey: 'AIzaSyBkjx1hu6Tl0_TpY9B8Ubgo4ZjGxTCeBwE',
    appId: '1:863088518689:web:5c3c07bd6f91d730276560',
    messagingSenderId: '863088518689',
    projectId: 'albanur-ks2008',
    authDomain: 'albanur-ks2008.firebaseapp.com',
    storageBucket: 'albanur-ks2008.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_vsBTfEY0yDfnUQDTxUkyAOhVRZ-rMkw',
    appId: '1:863088518689:android:8e852d1411df669c276560',
    messagingSenderId: '863088518689',
    projectId: 'albanur-ks2008',
    storageBucket: 'albanur-ks2008.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD2hnWps4weUPWV4G2lVjHNCzCYZJ5MpGY',
    appId: '1:863088518689:ios:5f1c999529a3916e276560',
    messagingSenderId: '863088518689',
    projectId: 'albanur-ks2008',
    storageBucket: 'albanur-ks2008.appspot.com',
    iosClientId: '863088518689-fe49f794tcp83t9vfabmvvv55qknudk5.apps.googleusercontent.com',
    iosBundleId: 'com.example.chat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD2hnWps4weUPWV4G2lVjHNCzCYZJ5MpGY',
    appId: '1:863088518689:ios:5f1c999529a3916e276560',
    messagingSenderId: '863088518689',
    projectId: 'albanur-ks2008',
    storageBucket: 'albanur-ks2008.appspot.com',
    iosClientId: '863088518689-fe49f794tcp83t9vfabmvvv55qknudk5.apps.googleusercontent.com',
    iosBundleId: 'com.example.chat',
  );
}
