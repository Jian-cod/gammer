import 'package:flutter/material.dart';
import 'video_feed_screen.dart';
import 'upload_screen.dart';
import 'live_stream_screen.dart';
import 'profile_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Text(
              'GAMMER Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.ondemand_video, color: Colors.white),
            title: const Text('Watch Videos'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoFeedScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload, color: Colors.white),
            title: const Text('Upload Video'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.live_tv, color: Colors.white),
            title: const Text('Go Live / Watch Live'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveStreamScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Profile'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
    );
  }
}