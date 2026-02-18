import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCsH9QR5vTlpU7Z9GJa9DLT8D2yVCu5Myo',
    appId: '1:25820351915:web:5d2c7eb61f80fc7e1b16ee',
    messagingSenderId: '25820351915',
    projectId: 'bcstep-942ed',
    authDomain: 'bcstep-942ed.firebaseapp.com',
    databaseURL: 'https://bcstep-942ed-default-rtdb.firebaseio.com',
    storageBucket: 'bcstep-942ed.firebasestorage.app',
    measurementId: 'G-GHS0T3XYE4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBxhvGia0WAiU6GM2WucCOVe1i96YO-X4',
    appId: '1:25820351915:android:bf881c8147606ea51b16ee',
    messagingSenderId: '25820351915',
    projectId: 'bcstep-942ed',
    databaseURL: 'https://bcstep-942ed-default-rtdb.firebaseio.com',
    storageBucket: 'bcstep-942ed.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKDUR8lxptrdEA7frmDHBqaiF1nz7xqSk',
    appId: '1:25820351915:ios:6dc80a7d4f49dab61b16ee',
    messagingSenderId: '25820351915',
    projectId: 'bcstep-942ed',
    databaseURL: 'https://bcstep-942ed-default-rtdb.firebaseio.com',
    storageBucket: 'bcstep-942ed.firebasestorage.app',
    iosBundleId: 'com.bcstep.tm.taskManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAKDUR8lxptrdEA7frmDHBqaiF1nz7xqSk',
    appId: '1:25820351915:ios:6dc80a7d4f49dab61b16ee',
    messagingSenderId: '25820351915',
    projectId: 'bcstep-942ed',
    databaseURL: 'https://bcstep-942ed-default-rtdb.firebaseio.com',
    storageBucket: 'bcstep-942ed.firebasestorage.app',
    iosBundleId: 'com.bcstep.tm.taskManager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCsH9QR5vTlpU7Z9GJa9DLT8D2yVCu5Myo',
    appId: '1:25820351915:web:8f69e1c4f1b5d1c61b16ee',
    messagingSenderId: '25820351915',
    projectId: 'bcstep-942ed',
    authDomain: 'bcstep-942ed.firebaseapp.com',
    databaseURL: 'https://bcstep-942ed-default-rtdb.firebaseio.com',
    storageBucket: 'bcstep-942ed.firebasestorage.app',
    measurementId: 'G-4TK1YMQCMF',
  );

}