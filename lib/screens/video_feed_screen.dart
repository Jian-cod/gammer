import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'reply_screen.dart'; // ✅ Add this import for reply functionality

class VideoFeedScreen extends StatelessWidget {
  const VideoFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Feed')),
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
              final videoUrl = videoData['videoUrl'];
              final likes = videoData['likes'] ?? 0;
              final videoId = videoData.id;

              return VideoPlayerItem(
                videoUrl: videoUrl,
                likes: likes,
                videoId: videoId,
              );
            },
          );
        },
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final int likes;
  final String videoId;

  const VideoPlayerItem({
    super.key,
    required this.videoUrl,
    required this.likes,
    required this.videoId,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });

    _likes = widget.likes;
  }

  void _likeVideo() async {
    final videoRef = FirebaseFirestore.instance.collection('videos').doc(widget.videoId);
    await videoRef.update({'likes': FieldValue.increment(1)});
    setState(() {
      _likes += 1;
    });
  }

  void _showCommentsDialog() {
    final commentController = TextEditingController();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Comments', style: TextStyle(fontSize: 20)),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('videos')
                      .doc(widget.videoId)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final comments = snapshot.data!.docs;

                    return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final text = comment['text'];
                          final commentId = comment.id;

                          return ListTile(
                            title: Text(text),
                            trailing: IconButton(
                              icon: const Icon(Icons.reply, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReplyScreen(
                                      videoId: widget.videoId,
                                      commentId: commentId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(hintText: 'Add a comment...'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          final text = commentController.text.trim();
                          if (text.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection('videos')
                                .doc(widget.videoId)
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
      children: [
        Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const CircularProgressIndicator(),
        ),
        Positioned(
          right: 20,
          bottom: 100,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red, size: 30),
                onPressed: _likeVideo,
              ),
              Text('$_likes', style: const TextStyle(fontSize: 16)),
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
