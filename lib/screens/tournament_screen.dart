import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _joinTournament(String tournamentId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final tournamentRef = _firestore.collection('tournaments').doc(tournamentId);
    final snapshot = await tournamentRef.get();

    final currentUsers = List<String>.from(snapshot.data()?['joinedUsers'] ?? []);

    if (!currentUsers.contains(user.uid)) {
      currentUsers.add(user.uid);
      await tournamentRef.update({'joinedUsers': currentUsers});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have joined this tournament')),
    );

    setState(() {}); // refresh the list to show updated users
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('tournaments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading tournaments'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tournaments = snapshot.data!.docs;

          if (tournaments.isEmpty) {
            return const Center(child: Text('No tournaments available'));
          }

          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final doc = tournaments[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Untitled';
              final description = data['description'] ?? '';
              final joinedUsers = List<String>.from(data['joinedUsers'] ?? []);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description),
                      const SizedBox(height: 6),
                      Text('Joined: ${joinedUsers.length}'),
                      if (joinedUsers.isNotEmpty)
                        Text(
                          'Users: ${joinedUsers.join(', ')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _joinTournament(doc.id),
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
