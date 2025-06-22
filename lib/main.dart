import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/host_tournament_screen.dart';
import 'screens/join_tournament_screen.dart';
import 'screens/payment_method_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/video_feed_screen.dart';
import 'screens/upload_video_screen.dart';
import 'screens/live_stream_screen.dart';
import 'screens/live_stream_list_screen.dart'; // ✅ Added live stream list screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCqtQFpF6mqu1B6YDfF0gdxRf9flwIAYwU",
        authDomain: "tournhost-c0860.firebaseapp.com",
        projectId: "tournhost-c0860",
        storageBucket: "tournhost-c0860.appspot.com",
        messagingSenderId: "439860969536",
        appId: "1:439860969536:web:e7ca11a1fe27f3a2fc5fa5",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const GammerApp());
}

class GammerApp extends StatelessWidget {
  const GammerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GAMMER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/host': (context) => const HostTournamentScreen(),
        '/join': (context) => const JoinTournamentScreen(),
        '/payment-method': (context) => const PaymentMethodScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/videos': (context) => const VideoFeedScreen(),
        '/upload': (context) => const UploadVideoScreen(),
        '/live': (context) => const LiveStreamScreen(),
        '/live-streams': (context) => const LiveStreamListScreen(), // ✅ Added
      },
    );
  }
}
