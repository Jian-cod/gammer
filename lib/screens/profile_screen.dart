import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/navigation_drawer.dart';
import '../helpers/auth_guard.dart';
import '../helpers/supabase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final nameController = TextEditingController();
  String? imageUrl;
  bool isLoading = true;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['name'] ?? '';
      imageUrl = data['imageUrl'];
    }
    setState(() => isLoading = false);
  }

  Future<void> _updateProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
      'name': nameController.text.trim(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Profile updated")),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;

    final file = File(picked.path);
    final url = await uploadProfilePicture(currentUser.uid, file);

    if (url != null && mounted) {
      setState(() => imageUrl = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard.guard(
      context,
      Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        drawer: const NavigationDrawerWidget(),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            imageUrl != null ? NetworkImage(imageUrl!) : null,
                        child: imageUrl == null
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Display Name'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text("Save Changes"),
                    ),
                    const SizedBox(height: 20),
                    Text("Email: ${currentUser.email}",
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async => await FirebaseAuth.instance.signOut(),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
