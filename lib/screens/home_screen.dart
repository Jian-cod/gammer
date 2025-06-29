import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GAMMER')),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          homeButton(context, 'Profile', '/profile'),
          homeButton(context, 'Create Tournament', '/create'),
          homeButton(context, 'Join Tournament', '/join'),
          homeButton(context, 'Watch Videos\n(COMING SOON)', '/watch'),
          homeButton(context, 'Upload Videos\n(COMING SOON)', '/upload'),
          homeButton(context, 'Go Live\n(COMING SOON)', '/live'),
          homeButton(context, 'Watch Live\n(COMING SOON)', '/watchlive'),
        ],
      ),
    );
  }

  Widget homeButton(BuildContext context, String label, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Center(child: Text(label, textAlign: TextAlign.center)),
    );
  }
}
