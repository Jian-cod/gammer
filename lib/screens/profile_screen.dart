import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/navigation_drawer.dart';
import '../helpers/auth_guard.dart'; // ✅ Import the AuthGuard

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard.guard( // ✅ Wrap the screen with the guard
      context,
      Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        drawer: const NavigationDrawerWidget(),
        body: Center(
          child: _buildProfileContent(),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.person, size: 100, color: Colors.white),
        const SizedBox(height: 20),
        Text(
          user?.email ?? 'No email available',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
