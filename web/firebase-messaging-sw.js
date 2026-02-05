importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

// Firebase config
const firebaseConfig = {
  apiKey: "AIzaSyCsH9QR5vTlpU7Z9GJa9DLT8D2yVCu5Myo",
  authDomain: "bcstep-942ed.firebaseapp.com",
  databaseURL: "https://bcstep-942ed-default-rtdb.firebaseio.com",
  projectId: "bcstep-942ed",
  storageBucket: "bcstep-942ed.firebasestorage.app",
  messagingSenderId: "25820351915",
  appId: "1:25820351915:web:5d2c7eb61f80fc7e1b16ee",
  measurementId: "G-GHS0T3XYE4"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log(
    '[firebase-messaging-sw.js] Background message received:',
    payload
  );

  // Customize notification options
  const notificationTitle = payload.notification?.title || 'New Notification';
  const notificationOptions = {
    body: payload.notification?.body || 'You have a new message',
    icon: payload.notification?.icon || '/icons/Icon-192.png',
    badge: '/icons/badge-72.png', // Optional: small monochrome icon
    tag: payload.data?.tag || 'default-tag', // Prevents duplicate notifications
    data: payload.data || {},
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});