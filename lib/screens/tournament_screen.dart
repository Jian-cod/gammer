import 'package:flutter/material.dart';

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
      ),
      body: const Center(
        child: Text(
          'Coming Soon: Game Tournaments',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
