import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class DmRequestsScreen extends StatelessWidget {
  const DmRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirestoreService.currentUserId();

    return Scaffold(
      appBar: AppBar(title: const Text('DM Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dmRequests')
            .where('to', isEqualTo: uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final fromUserId = doc['from'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData || !userSnap.data!.exists) {
  return const ListTile(title: Text('Loading...'));
}

final fromName = userSnap.data!.get('name') ?? 'Unknown';


                  return ListTile(
                    title: Text('From: $fromName'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () async {
                            await FirestoreService.respondDmRequest(doc.id, true);

                            final chatId = await FirestoreService.openChat(
                              {uid, fromUserId},
                              true,
                            );

                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chatId,
                                  receiverId: fromUserId,
                                  receiverName: fromName,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            FirestoreService.respondDmRequest(doc.id, false);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
