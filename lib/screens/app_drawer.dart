import 'package:flutter/material.dart';

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
            onTap: () => Navigator.pushNamed(context, '/home'),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload, color: Colors.white),
            title: const Text('Upload Video'),
            onTap: () => Navigator.pushNamed(context, '/upload'),
          ),
          ListTile(
            leading: const Icon(Icons.live_tv, color: Colors.white),
            title: const Text('Go Live'),
            onTap: () => Navigator.pushNamed(context, '/live'),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.white),
            title: const Text('Create Tournament'),
            onTap: () => Navigator.pushNamed(context, '/create_tournament'),
          ),
          ListTile(
            leading: const Icon(Icons.group, color: Colors.white),
            title: const Text('Join Tournament'),
            onTap: () => Navigator.pushNamed(context, '/join_tournament'),
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
            title: const Text('Host Tournament'),
            onTap: () => Navigator.pushNamed(context, '/host_tournament'),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Profile'),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }
}
