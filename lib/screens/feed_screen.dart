import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GAMMER Feed")),
      body: const Center(child: Text("Welcome to GAMMER!")),
    );
  }
}
