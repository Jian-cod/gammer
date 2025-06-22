import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinTournamentScreen extends StatelessWidget {
  const JoinTournamentScreen({super.key});

  Future<void> _joinTournament(String tournamentId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final participantRef = FirebaseFirestore.instance
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .doc(user.uid);

    final doc = await participantRef.get();

    if (!doc.exists) {
      await participantRef.set({
        'userId': user.uid,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Tournaments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading tournaments.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tournaments = snapshot.data!.docs;

          if (tournaments.isEmpty) {
            return const Center(child: Text("No tournaments available."));
          }

          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final data = tournaments[index].data() as Map<String, dynamic>;
              final docId = tournaments[index].id;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['title'] ?? 'No Title'),
                  subtitle: Text("Game: ${data['game']} | Fee: KES ${data['entryFee']}"),
                  trailing: ElevatedButton(
                    onPressed: () => _joinTournament(docId),
                    child: const Text("Join"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
