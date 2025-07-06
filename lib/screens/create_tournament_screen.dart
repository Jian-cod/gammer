import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/auth_guard.dart';
import '../widgets/navigation_drawer.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final nameController = TextEditingController();
  bool isLoading = false;

  Future<void> createTournament() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || nameController.text.trim().isEmpty) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('tournaments').add({
        'name': nameController.text.trim(),
        'createdBy': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Tournament created')),
      );

      nameController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard.guard(
      context,
      Scaffold(
        appBar: AppBar(title: const Text('Create Tournament')),
        drawer: const NavigationDrawerWidget(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tournament Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : createTournament,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Tournament'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
