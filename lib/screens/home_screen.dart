// lib/screen/home_screen.dart

import 'package:flutter/material.dart';
import 'tournament_screen.dart'; // ✅ Make sure this file exists

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GAMMER'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'GAMMER MENU',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create Tournament'),
              onTap: () {
                Navigator.pushNamed(context, '/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_esports),
              title: const Text('Tournaments'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TournamentScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.ondemand_video),
              title: const Text('Watch Videos'),
              onTap: () {
                Navigator.pushNamed(context, '/watch');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Upload Videos'),
              onTap: () {
                Navigator.pushNamed(context, '/upload');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Go Live'),
              onTap: () {
                Navigator.pushNamed(context, '/live');
              },
            ),
            ListTile(
              leading: const Icon(Icons.live_tv),
              title: const Text('Watch Live'),
              onTap: () {
                Navigator.pushNamed(context, '/watchlive');
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Welcome to GAMMER!',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
