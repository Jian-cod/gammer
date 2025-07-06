import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinTournamentScreen extends StatelessWidget {
  const JoinTournamentScreen({super.key});

  void _joinTournament(String tournamentId, String userId) async {
    final docRef = FirebaseFirestore.instance
        .collection('tournaments')
        .doc(tournamentId);

    final joinedRef = docRef.collection('joinedUsers').doc(userId);

    final alreadyJoined = await joinedRef.get();

    if (!alreadyJoined.exists) {
      await joinedRef.set({
        'userId': userId,
        'joinedAt': Timestamp.now(),
      });
    }
  }

  void _showJoinedUsers(BuildContext context, String tournamentId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tournaments')
              .doc(tournamentId)
              .collection('joinedUsers')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final users = snapshot.data!.docs;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Joined Users:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                ...users.map((doc) {
                  final userId = doc['userId'];
                  return ListTile(
                    title: Text(userId),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Join Tournament')),
        body: const Center(
          child: Text('Please log in to view and join tournaments.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Join Tournament')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final tournaments = snapshot.data!.docs;

          if (tournaments.isEmpty) {
            return const Center(child: Text('No tournaments available.'));
          }

          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final doc = tournaments[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _joinTournament(doc.id, user.uid);
                      _showJoinedUsers(context, doc.id);
                    },
                    child: const Text('Join'),
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
