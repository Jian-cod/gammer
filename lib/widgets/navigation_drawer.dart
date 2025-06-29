import 'package:flutter/material.dart';
import '../screens/videos_screen.dart';
import '../screens/upload_screen.dart';
import '../screens/live_stream_screen.dart';

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey),
            child: Text('GAMMER Menu', style: TextStyle(fontSize: 20)),
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Watch Videos'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VideosScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Upload Videos'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UploadScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.live_tv),
            title: const Text('Go Live'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LiveStreamScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
