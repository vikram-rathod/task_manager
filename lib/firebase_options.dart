import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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
    apiKey: 'AIzaSyBBxhvGia0WAiU6GM2WucCOVe1i96YO-X4',
    appId: '1:25820351915:android:bf881c8147606ea51b16ee',
    messagingSenderId: '25820351915',
    projectId: 'bcstep-942ed',
    storageBucket: 'bcstep-942ed.firebasestorage.app',
    databaseURL: 'https://bcstep-942ed-default-rtdb.firebaseio.com',
  );

  // Fill in once you add an iOS app in Firebase console
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBxhvGia0WAiU6GM2WucCOVe1i96YO-X4',
    appId: '1:25820351915:android:bf881c8147606ea51b16ee',
    messagingSenderId: '25820351915',
    projectId: 'bcstep-942ed',
    storageBucket: 'bcstep-942ed.firebasestorage.app',
    iosBundleId: 'com.bcstep.tm',
  );
}