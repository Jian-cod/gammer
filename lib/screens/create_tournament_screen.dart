import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final nameController = TextEditingController();

  Future<void> createTournament() async {
    if (nameController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('tournaments').add({
      'name': nameController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ✅ Correct usage: mounted is from State class
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tournament created')),
    );

    nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Tournament')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tournament Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: createTournament,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
