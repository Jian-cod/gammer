import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinTournamentScreen extends StatefulWidget {
  const JoinTournamentScreen({super.key});

  @override
  State<JoinTournamentScreen> createState() => _JoinTournamentScreenState();
}

class _JoinTournamentScreenState extends State<JoinTournamentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final int _pageSize = 10;

  List<DocumentSnapshot> _tournaments = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments({bool isRefresh = false}) async {
    if (_isLoading || (!_hasMore && !isRefresh)) return;

    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('tournaments')
        .orderBy('timestamp', descending: true)
        .limit(_pageSize);

    if (_lastDoc != null && !isRefresh) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (isRefresh) {
      _tournaments = snapshot.docs;
    } else {
      _tournaments.addAll(snapshot.docs);
    }

    if (snapshot.docs.length < _pageSize) _hasMore = false;
    if (_tournaments.isNotEmpty) _lastDoc = _tournaments.last;

    setState(() => _isLoading = false);
  }

  List<DocumentSnapshot> _filterTournaments(String search) {
    return _tournaments.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = data['title']?.toLowerCase() ?? '';
      final host = data['hostedBy']?.toLowerCase() ?? '';
      return title.contains(search.toLowerCase()) || host.contains(search.toLowerCase());
    }).toList();
  }

  Future<void> _joinTournament(DocumentSnapshot doc) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please log in to join")),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final displayName = userDoc.data()?['displayName'] ?? user.email ?? 'Unknown';

    final docRef = FirebaseFirestore.instance.collection('tournaments').doc(doc.id);
    final snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;

    final List currentParticipants = data['participants'] ?? [];

    if (currentParticipants.contains(displayName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ You already joined this tournament")),
      );
      return;
    }

    await docRef.update({
      'participants': FieldValue.arrayUnion([displayName])
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Successfully joined")),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredTournaments = _searchController.text.isEmpty
        ? _tournaments
        : _filterTournaments(_searchController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Tournament'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _tournaments.clear();
              _lastDoc = null;
              _hasMore = true;
              _loadTournaments(isRefresh: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by title or host...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _tournaments.clear();
                _lastDoc = null;
                _hasMore = true;
                await _loadTournaments(isRefresh: true);
              },
              child: ListView.builder(
                itemCount: filteredTournaments.length + 1,
                itemBuilder: (context, index) {
                  if (index < filteredTournaments.length) {
                    final doc = filteredTournaments[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final participants = List<String>.from(data['participants'] ?? []);

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
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
                            Text("Date: ${data['date'] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white70)),
                            if ((data['description'] ?? '').isNotEmpty)
                              Text("Prize: ${data['description']}",
                                  style: const TextStyle(color: Colors.greenAccent)),
                            const SizedBox(height: 6),
                            const Text("Participants:",
                                style: TextStyle(color: Colors.amber)),
                            for (final name in participants)
                              Text("- $name",
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _joinTournament(doc),
                          child: const Text("Join"),
                        ),
                      ),
                    );
                  } else if (_hasMore) {
                    _loadTournaments();
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return const SizedBox(height: 20);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
