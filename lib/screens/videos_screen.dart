import 'package:flutter/material.dart';
import 'app_drawer.dart'; // ✅ Make sure this file exists in the same folder

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GAMMER'),
        backgroundColor: Colors.black,
      ),
      drawer: const AppDrawer(), // ✅ Navigation drawer
      body: const Center(
        child: Text(
          'Video Feed Coming Soon',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black, // ✅ Ensures dark background
    );
  }
}
