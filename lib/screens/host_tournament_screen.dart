import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/auth_guard.dart';
import '../widgets/navigation_drawer.dart';

class HostTournamentScreen extends StatefulWidget {
  const HostTournamentScreen({super.key});

  @override
  State<HostTournamentScreen> createState() => _HostTournamentScreenState();
}

class _HostTournamentScreenState extends State<HostTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gameController = TextEditingController();
  final _titleController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _gameController.dispose();
    _titleController.dispose();
    _entryFeeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submitTournament() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ You must be logged in to host.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('tournaments').add({
        'game': _gameController.text.trim(),
        'title': _titleController.text.trim(),
        'entryFee': int.tryParse(_entryFeeController.text.trim()) ?? 0,
        'date': _dateController.text.trim(),
        'hostedBy': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Tournament Hosted Successfully")),
      );

      _formKey.currentState!.reset();
      _gameController.clear();
      _titleController.clear();
      _entryFeeController.clear();
      _dateController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard.guard(
      context,
      Scaffold(
        appBar: AppBar(title: const Text("Host Tournament")),
        drawer: const NavigationDrawerWidget(),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _gameController,
                  decoration: const InputDecoration(labelText: 'Game'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter game name' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tournament Title'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _entryFeeController,
                  decoration: const InputDecoration(labelText: 'Entry Fee (KES)'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter entry fee' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter date' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitTournament,
                  child: const Text("Host Tournament"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
