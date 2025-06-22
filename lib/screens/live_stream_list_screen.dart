import 'package:flutter/material.dart';

class LiveStreamListScreen extends StatelessWidget {
  const LiveStreamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy list of live streams
    final List<Map<String, String>> liveStreams = [
      {'title': '🔥 Battle Royale - Kenya Finals', 'host': 'GamerX'},
      {'title': '🎮 1v1 Clash: Pro vs Noob', 'host': 'Legendz'},
      {'title': '👾 Squad Wipeout Live', 'host': 'KillerBee'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Streams'),
      ),
      body: ListView.builder(
        itemCount: liveStreams.length,
        itemBuilder: (context, index) {
          final stream = liveStreams[index];
          return ListTile(
            leading: const Icon(Icons.live_tv, color: Colors.redAccent),
            title: Text(stream['title'] ?? ''),
            subtitle: Text('Hosted by ${stream['host']}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Later: Navigate to watch this stream
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Joining "${stream['title']}"...')),
                );
              },
              child: const Text('Join'),
            ),
          );
        },
      ),
    );
  }
}
