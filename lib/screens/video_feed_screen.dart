import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';

import 'reply_screen.dart';
import 'app_drawer.dart';

class VideoFeedScreen extends StatelessWidget {
  const VideoFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GAMMER - Videos'),
        backgroundColor: Colors.black,
      ),
      drawer: const AppDrawer(),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final videos = snapshot.data!.docs;

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final videoData = videos[index];
              return VideoPlayerItem(videoData: videoData);
            },
          );
        },
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final DocumentSnapshot videoData;

  const VideoPlayerItem({super.key, required this.videoData});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  int _likes = 0;
  late String _videoId;
  late String _videoUrl;

  @override
  void initState() {
    super.initState();

    _videoId = widget.videoData.id;
    _videoUrl = widget.videoData['videoUrl'];
    _likes = widget.videoData['likes'] ?? 0;

    _controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  void _likeVideo() async {
    final ref = FirebaseFirestore.instance.collection('videos').doc(_videoId);
    await ref.update({'likes': FieldValue.increment(1)});
    setState(() {
      _likes += 1;
    });
  }

  void _showCommentsDialog() {
    final commentController = TextEditingController();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Comments', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
                SizedBox(
                  height: 250,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('videos')
                        .doc(_videoId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final text = comment['text'] ?? '';
                          final commentId = comment.id;

                          return ListTile(
                            title: Text(text, style: const TextStyle(color: Colors.white)),
                            trailing: IconButton(
                              icon: const Icon(Icons.reply, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReplyScreen(
                                      videoId: _videoId,
                                      commentId: commentId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.redAccent),
                        onPressed: () async {
                          final text = commentController.text.trim();
                          if (text.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection('videos')
                                .doc(_videoId)
                                .collection('comments')
                                .add({
                              'text': text,
                              'uid': uid,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                            commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _controller.value.isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
        Positioned(
          right: 20,
          bottom: 100,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red, size: 30),
                onPressed: _likeVideo,
              ),
              Text('$_likes', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              IconButton(
                icon: const Icon(Icons.comment, color: Colors.white, size: 28),
                onPressed: _showCommentsDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
