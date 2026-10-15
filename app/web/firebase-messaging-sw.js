// Background web push (FCM). The Firebase JS SDK registers this file at
// /firebase-messaging-sw.js when the app asks for a push token.
//
// Config comes from Firebase Hosting's reserved /__/firebase/init.js, so no
// keys live in the repo. That URL only exists on Firebase Hosting (including
// custom domains) — under `flutter run` background push is simply off.
//
// Keep the SDK version in step with firebase_core_web's
// supportedFirebaseJsSdkVersion.
importScripts("https://www.gstatic.com/firebasejs/11.9.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/11.9.1/firebase-messaging-compat.js");
importScripts("/__/firebase/init.js");

// Pushes carry a `notification` block, which the SDK shows by itself;
// tapping opens webpush.fcmOptions.link (set by onNotificationCreated).
firebase.messaging();
