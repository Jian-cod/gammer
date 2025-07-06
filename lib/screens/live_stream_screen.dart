import 'package:flutter/material.dart';
import '../widgets/navigation_drawer.dart';
// import '../helpers/auth_guard.dart'; // ✅ Uncomment this if you want to restrict to logged-in users

class LiveStreamScreen extends StatelessWidget {
  const LiveStreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      appBar: AppBar(
        title: const Text('Go Live'),
      ),
      drawer: const NavigationDrawerWidget(),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.live_tv, size: 100, color: Colors.redAccent),
              SizedBox(height: 20),
              Text(
                "Live streaming is coming soon!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    // ✅ Uncomment below if you want to restrict "Go Live" to only logged-in users
    // return AuthGuard.guard(context, content);

    return content;
  }
}
