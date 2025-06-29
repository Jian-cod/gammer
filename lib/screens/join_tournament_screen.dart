import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinTournamentScreen extends StatelessWidget {
  const JoinTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Tournament')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tournaments').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final tournaments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final data = tournaments[index].data() as Map<String, dynamic>;
              return ListTile(title: Text(data['name'] ?? 'No Name'));
            },
          );
        },
      ),
    );
  }
}
