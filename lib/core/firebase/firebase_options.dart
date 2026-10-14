import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Configure these default credentials or override them by adding your
/// `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
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
    apiKey: 'AIzaSyBvtvOKWHImzzkLKYN2eAuLBG1wMS4hm80',
    appId: '1:538470397018:web:50df20bbfb5d655a399463',
    messagingSenderId: '538470397018',
    projectId: 'driverbooking-4b700',
    authDomain: 'driverbooking-4b700.firebaseapp.com',
    storageBucket: 'driverbooking-4b700.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvtvOKWHImzzkLKYN2eAuLBG1wMS4hm80',
    appId: '1:538470397018:android:50df20bbfb5d655a399463',
    messagingSenderId: '538470397018',
    projectId: 'driverbooking-4b700',
    storageBucket: 'driverbooking-4b700.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvtvOKWHImzzkLKYN2eAuLBG1wMS4hm80',
    appId: '1:538470397018:ios:50df20bbfb5d655a399463',
    messagingSenderId: '538470397018',
    projectId: 'driverbooking-4b700',
    storageBucket: 'driverbooking-4b700.firebasestorage.app',
    iosBundleId: 'com.example.cardriver',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBvtvOKWHImzzkLKYN2eAuLBG1wMS4hm80',
    appId: '1:538470397018:ios:50df20bbfb5d655a399463',
    messagingSenderId: '538470397018',
    projectId: 'driverbooking-4b700',
    storageBucket: 'driverbooking-4b700.firebasestorage.app',
    iosBundleId: 'com.example.cardriver',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBvtvOKWHImzzkLKYN2eAuLBG1wMS4hm80',
    appId: '1:538470397018:web:50df20bbfb5d655a399463',
    messagingSenderId: '538470397018',
    projectId: 'driverbooking-4b700',
    authDomain: 'driverbooking-4b700.firebaseapp.com',
    storageBucket: 'driverbooking-4b700.firebasestorage.app',
  );
}
