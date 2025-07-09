import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';

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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("🔔 Background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("🔥 Firebase init failed: $e");
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
        '/profile': (context) => AuthGuard.guard(context, const ProfileScreen()),
        '/upload': (context) => AuthGuard.guard(context, const UploadScreen()),
        '/live': (context) => AuthGuard.guard(context, const LiveStreamScreen()),
        '/create_tournament': (context) => AuthGuard.guard(context, const CreateTournamentScreen()),
        '/join_tournament': (context) => AuthGuard.guard(context, const JoinTournamentScreen()),
        '/host_tournament': (context) => AuthGuard.guard(context, const HostTournamentScreen()),
      },
    );
  }
}
