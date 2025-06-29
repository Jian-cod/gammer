import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReplyScreen extends StatefulWidget {
  final String videoId;
  final String commentId;

  const ReplyScreen({
    super.key,
    required this.videoId,
    required this.commentId,
  });

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  final replyController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

  @override
  Widget build(BuildContext context) {
    final repliesRef = FirebaseFirestore.instance
        .collection('videos')
        .doc(widget.videoId)
        .collection('comments')
        .doc(widget.commentId)
        .collection('replies');

    return Scaffold(
      appBar: AppBar(title: const Text('Replies')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: repliesRef.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final replies = snapshot.data!.docs;

                if (replies.isEmpty) {
                  return const Center(child: Text('No replies yet.'));
                }

                return ListView.builder(
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply = replies[index]['text'];
                    return ListTile(title: Text(reply));
                  },
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyController,
                    decoration: const InputDecoration(hintText: 'Write a reply...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = replyController.text.trim();
                    if (text.isNotEmpty) {
                      await repliesRef.add({
                        'text': text,
                        'uid': uid,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      replyController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
