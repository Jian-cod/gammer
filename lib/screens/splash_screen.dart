import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/firebase_messaging_service.dart';
import '../firebase_options.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseMessagingService.initialize(context);
    final user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 2)); // Optional delay

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, user != null ? '/' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
