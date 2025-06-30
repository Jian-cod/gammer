import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'screens/videos_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/live_stream_screen.dart';
import 'screens/create_tournament_screen.dart';
import 'screens/join_tournament_screen.dart';
import 'screens/host_tournament_screen.dart';

import 'services/firebase_messaging_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background notifications here (optional)
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/upload': (context) => const UploadScreen(),
        '/live': (context) => const LiveStreamScreen(),
        '/create_tournament': (context) => const CreateTournamentScreen(),
        '/join_tournament': (context) => const JoinTournamentScreen(),
        '/host_tournament': (context) => const HostTournamentScreen(),
        '/home': (context) => const VideosScreen(),
      },
      home: const EntryScreen(),
    );
  }
}

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseMessagingService.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    return const VideosScreen();
  }
}
