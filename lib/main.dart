import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/live_stream_screen.dart';
import 'screens/create_tournament_screen.dart';
import 'screens/join_tournament_screen.dart';
import 'screens/host_tournament_screen.dart';
import 'screens/main_navigation_screen.dart';

import 'helpers/auth_guard.dart';

/// Handle background messages for Firebase Cloud Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("🔔 Background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Register background FCM handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ✅ Initialize Supabase
    await Supabase.initialize(
      url: "https://rsugjempmrszbfyagskm.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzdWdqZW1wbXJzemJmeWFnc2ttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyNDcxMzYsImV4cCI6MjA2OTgyMzEzNn0.jro90wFa_xb5MH6VrCSA5vwt_9GM6OkOB5EdJfoyREg",
    );

    debugPrint("✅ Firebase and Supabase initialized successfully");
  } catch (e) {
    debugPrint("🔥 Initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GAMMER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const MainNavigationScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/profile': (context) =>
            AuthGuard.guard(context, const ProfileScreen()),
        '/upload': (context) =>
            AuthGuard.guard(context, const UploadScreen()),
        '/live': (context) =>
            AuthGuard.guard(context, const LiveStreamScreen()),
        '/create_tournament': (context) =>
            AuthGuard.guard(context, const CreateTournamentScreen()),
        '/join_tournament': (context) =>
            AuthGuard.guard(context, const JoinTournamentScreen()),
        '/host_tournament': (context) =>
            AuthGuard.guard(context, const HostTournamentScreen()),
      },
    );
  }
}
