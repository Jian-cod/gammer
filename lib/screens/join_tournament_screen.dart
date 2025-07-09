import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JoinTournamentScreen extends StatefulWidget {
  const JoinTournamentScreen({super.key});

  @override
  State<JoinTournamentScreen> createState() => _JoinTournamentScreenState();
}

class _JoinTournamentScreenState extends State<JoinTournamentScreen> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _selectedGame = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Tournaments'),
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search by title or host...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 🎮 Game filter dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Text("Filter by game: ", style: TextStyle(color: Colors.white)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedGame,
                  dropdownColor: Colors.grey[900],
                  items: <String>['All', 'COD', 'PUBG', 'Free Fire', 'Fortnite']
                      .map((game) => DropdownMenuItem(
                            value: game,
                            child: Text(game, style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedGame = value ?? 'All');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔄 Pull-to-refresh + list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tournaments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // 🔍 Search + filter
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title']?.toLowerCase() ?? '';
                  final host = data['hostedBy']?.toLowerCase() ?? '';
                  final game = data['game']?.toLowerCase() ?? '';
                  final search = _searchController.text.toLowerCase();

                  final matchesSearch = title.contains(search) || host.contains(search);
                  final matchesGame = _selectedGame == 'All' || game == _selectedGame.toLowerCase();
                  return matchesSearch && matchesGame;
                }).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {}); // Just reload stream
                  },
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final participants = List<String>.from(data['participants'] ?? []);

                      final currentUser = _auth.currentUser;
                      final currentName = currentUser?.email ?? '';

                      final alreadyJoined = participants.contains(currentName);

                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: ListTile(
                          leading: Icon(_getGameIcon(data['game']), color: Colors.cyanAccent),
                          title: Text(data['title'] ?? 'Untitled',
                              style: const TextStyle(fontSize: 18, color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Game: ${data['game'] ?? 'N/A'}",
                                  style: const TextStyle(color: Colors.white70)),
                              Text("Host: ${data['hostedBy'] ?? 'N/A'}",
                                  style: const TextStyle(color: Colors.white70)),
                              Text("Entry Fee: ${data['entryFee']} KES",
                                  style: const TextStyle(color: Colors.white70)),
                              Text("Date: ${data['date']} @ ${data['time']}",
                                  style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 4),
                              if ((data['description'] ?? '').isNotEmpty)
                                Text("Prize: ${data['description']}",
                                    style: const TextStyle(color: Colors.greenAccent)),
                              const SizedBox(height: 6),
                              const Text("Participants:",
                                  style: TextStyle(color: Colors.amber)),
                              for (final name in participants)
                                Text("- $name",
                                    style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                          trailing: alreadyJoined
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : ElevatedButton(
                                  onPressed: () => _joinTournament(doc),
                                  child: const Text("Join"),
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinTournament(DocumentSnapshot doc) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please log in to join")),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final name = userDoc.exists && userDoc.data()!.containsKey('name')
          ? userDoc['name']
          : user.email ?? 'Anonymous';

      final tournamentRef = FirebaseFirestore.instance.collection('tournaments').doc(doc.id);
      final currentData = doc.data() as Map<String, dynamic>;
      final currentParticipants = List<String>.from(currentData['participants'] ?? []);

      if (currentParticipants.contains(name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Already joined.")),
        );
        return;
      }

      await tournamentRef.update({
        'participants': FieldValue.arrayUnion([name])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Joined tournament!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to join: $e")),
        );
      }
    }
  }

  IconData _getGameIcon(String? game) {
    switch (game?.toLowerCase()) {
      case 'cod':
        return Icons.military_tech;
      case 'pubg':
        return Icons.sports_esports;
      case 'free fire':
        return Icons.whatshot;
      case 'fortnite':
        return Icons.flash_on;
      default:
        return Icons.videogame_asset;
    }
  }
}
