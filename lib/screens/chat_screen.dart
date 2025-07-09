import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = {
      'text': text,
      'senderId': currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    // Create chat doc if it doesn't exist
    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) {
      await chatRef.set({
        'users': [currentUser!.uid, widget.receiverId],
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await chatRef.update({
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await chatRef.collection('messages').add(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == currentUser!.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
