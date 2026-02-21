import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // if (kIsWeb) {
    //   return web;
    // }
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
    apiKey: 'AIzaSyCELA-HYDcuz4vb71QwBsAwhdvXssQ5Utg',
    appId: '1:288444136700:android:4a40889d280b39ebf62b79',
    messagingSenderId: '288444136700',
    projectId: 'bcstep-tm',
    storageBucket: 'bcstep-tm.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKDUR8lxptrdEA7frmDHBqaiF1nz7xqSk',
    appId: '1:288444136700:android:4a40889d280b39ebf62b79',
    messagingSenderId: '288444136700',
    projectId: 'bcstep-tm',
    storageBucket: 'bcstep-942ed.firebasestorage.app',
    iosBundleId: 'bcstep-tm.firebasestorage.app',
  );


}