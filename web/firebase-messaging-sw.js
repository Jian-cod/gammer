// web/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/10.14.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBaiyP19xTV3CdtGhrAbKsRq6atOVmCD_M",
  authDomain: "gammer-test.firebaseapp.com",
  projectId: "gammer-test",
  storageBucket: "gammer-test.appspot.com", // ✅ correct format
  messagingSenderId: "318544045968",
  appId: "1:318544045968:web:3bab38ee945f51f4793515"
});

const messaging = firebase.messaging();
