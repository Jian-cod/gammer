import 'package:flutter/material.dart';
import 'app_drawer.dart'; // ✅ Correct path (if in same folder)


class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        backgroundColor: Colors.black,
      ),
      drawer: const AppDrawer(), // ← Make sure this is added
      body: const Center(
        child: Text(
          'Video Feed Coming Soon',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
