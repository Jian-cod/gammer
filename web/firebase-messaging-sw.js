// web/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/10.14.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCm89FZ-skQZSW1-uy0DBtxF3BZqHBL4sg",
  authDomain: "gammer-fixed.firebaseapp.com",
  projectId: "gammer-fixed",
  storageBucket: "gammer-fixed.appspot.com", // ✅ fixed `.firebasestorage.app` typo
  messagingSenderId: "563746270812",
  appId: "1:563746270812:web:13a93c32ff655d51640099"
});

const messaging = firebase.messaging();
