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
  final _nameController = TextEditingController();
  final _gameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _gameController.dispose();
    _descriptionController.dispose();
    _entryFeeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<bool> _hasExistingTournament(String uid) async {
    final query = await FirebaseFirestore.instance
        .collection('tournaments')
        .where('hostedBy', isEqualTo: uid)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> _submitTournament() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please log in to host.")),
      );
      return;
    }

    final hasOne = await _hasExistingTournament(user.uid);
    if (hasOne) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ You can only host 1 tournament at a time.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('tournaments').add({
        'name': _nameController.text.trim(),
        'game': _gameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'entryFee': int.tryParse(_entryFeeController.text.trim()) ?? 0,
        'date': _dateController.text.trim(),
        'time': _timeController.text.trim(),
        'hostedBy': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Tournament Hosted Successfully")),
      );

      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to save: $e")),
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
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tournament Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _gameController,
                  decoration: const InputDecoration(labelText: 'Game'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description / Prize Info'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _entryFeeController,
                  decoration: const InputDecoration(labelText: 'Entry Fee (KES)'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: 'Time (HH:MM AM/PM)'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
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
