import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;

        await FirebaseFirestore.instance.collection('tournaments').add({
          'game': _gameController.text,
          'title': _titleController.text,
          'entryFee': int.parse(_entryFeeController.text),
          'date': _dateController.text,
          'hostedBy': user?.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🎉 Tournament Hosted Successfully")),
        );

        // Optional: Clear form
        _gameController.clear();
        _titleController.clear();
        _entryFeeController.clear();
        _dateController.clear();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Failed to save: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Host Tournament")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    value == null || value.isEmpty ? 'Enter fee' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (e.g. 2025-06-30)'),
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
    );
  }
}
