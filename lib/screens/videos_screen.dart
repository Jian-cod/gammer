import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final PageController _pageController = PageController();
  List<DocumentSnapshot> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('videos')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      _videos = snapshot.docs;
      _isLoading = false;
    });
  }

  Future<void> _likeVideo(String videoId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('videos').doc(videoId);
    final doc = await docRef.get();

    final likes = List<String>.from(doc['likes'] ?? []);
    if (likes.contains(user.uid)) {
      await docRef.update({'likes': FieldValue.arrayRemove([user.uid])});
    } else {
      await docRef.update({'likes': FieldValue.arrayUnion([user.uid])});
    }
  }

  void _showBottomOptions(String videoUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy, color: Colors.white),
            title: const Text('Copy Link', style: TextStyle(color: Colors.white)),
            onTap: () {
              Clipboard.setData(ClipboardData(text: videoUrl));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: const Text('Link copied. Share manually.', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No videos yet", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final data = _videos[index].data() as Map<String, dynamic>;
          final videoUrl = data['videoUrl'] ?? '';
          final videoId = _videos[index].id;
          final likes = List<String>.from(data['likes'] ?? []);
          final isLiked = FirebaseAuth.instance.currentUser != null &&
              likes.contains(FirebaseAuth.instance.currentUser!.uid);

          return Stack(
            fit: StackFit.expand,
            children: [
              _VideoPlayerItem(videoUrl: videoUrl),
              Positioned(
                right: 10,
                bottom: 100,
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.redAccent,
                        size: 30,
                      ),
                      onPressed: () => _likeVideo(videoId),
                    ),
                    Text('${likes.length}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: () => _showBottomOptions(videoUrl),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerItem({required this.videoUrl});

  @override
  State<_VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<_VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() => _initialized = true);
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
