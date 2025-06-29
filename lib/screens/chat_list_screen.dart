import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder(
        stream: FirestoreService.fetchChats(),
        builder: (c, snap) {
          if (!snap.hasData) return const CircularProgressIndicator();
          final docs = snap.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i];
              final mems = List<String>.from(data['members']);
              return ListTile(
                title: Text(data['isGroup'] ? 'Group chat' : 'Chat with ${mems.firstWhere((id) => id != FirestoreService.currentUserId())}'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatScreen(chatId: data.id, members: mems),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
