import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final List<String> members;
  const ChatScreen({required this.chatId, required this.members, super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgController = TextEditingController();
  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.members.length == 2 ? 'Chat' : 'Group Chat')),
      body: Column(children: [
        Expanded(child: StreamBuilder(
          stream: FirestoreService.fetchMessages(widget.chatId),
          builder: (c, snap) {
            if (!snap.hasData) return const SizedBox();
            return ListView(
              reverse: true,
              children: snap.data!.docs.map((d) {
                final text = d['text'];
                final from = d['from'];
                final isMine = from == FirestoreService.currentUserId();
                return ListTile(
                  title: Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isMine ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(text),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        )),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
              child: TextField(controller: msgController, decoration: const InputDecoration(hintText: 'Message')),
            ),
            IconButton(
              icon: const Icon(Icons.send), 
              onPressed: () {
                final t = msgController.text.trim();
                if (t.isNotEmpty) {
                  FirestoreService.sendMessage(widget.chatId, t);
                  msgController.clear();
                }
              },
            )
          ]),
        )
      ]),
    );
  }
}
