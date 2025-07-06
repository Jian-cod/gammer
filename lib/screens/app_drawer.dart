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
          _buildDrawerItem(
            context,
            icon: Icons.ondemand_video,
            label: 'Watch Videos',
            routeName: '/home',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.file_upload,
            label: 'Upload Video',
            routeName: '/upload',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.live_tv,
            label: 'Go Live',
            routeName: '/live',
          ),
          const Divider(color: Colors.white30),
          _buildDrawerItem(
            context,
            icon: Icons.emoji_events,
            label: 'Create Tournament',
            routeName: '/create_tournament',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.group,
            label: 'Join Tournament',
            routeName: '/join_tournament',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.admin_panel_settings,
            label: 'Host Tournament',
            routeName: '/host_tournament',
          ),
          const Divider(color: Colors.white30),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            label: 'Profile',
            routeName: '/profile',
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context,
      {required IconData icon, required String label, required String routeName}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // ✅ Close drawer
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}
