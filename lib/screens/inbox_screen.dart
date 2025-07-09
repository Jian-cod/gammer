import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Inbox")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final chatDocs = snapshot.data!.docs;

          if (chatDocs.isEmpty) {
            return const Center(child: Text("No conversations yet"));
          }

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chat = chatDocs[index];
              final users = List<String>.from(chat['users']);
              final otherUserId = users.firstWhere((uid) => uid != currentUser.uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  final otherUserData = userSnap.data!;
                  final otherUserName = otherUserData['name'] ?? 'Unknown';

                  return ListTile(
                    title: Text(otherUserName),
                    subtitle: Text(chat['lastMessage'] ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chat.id,
                            receiverId: otherUserId,
                            receiverName: otherUserName,
                          ),
                        ),
                      );
                    },
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
