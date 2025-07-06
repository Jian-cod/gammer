import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGuard {
  static Widget guard(BuildContext context, Widget guardedPage) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return guardedPage; // ✅ User is logged in
    } else {
      // ❌ User is not logged in, redirect to login
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
