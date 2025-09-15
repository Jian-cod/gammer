import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../helpers/supabase_video.dart'; // Correct video helper

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  UploadScreenState createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  XFile? _videoFile;
  VideoPlayerController? _videoController;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final picker = ImagePicker();

  Future<void> _pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _videoFile = pickedFile;

      if (!kIsWeb) {
        final file = File(_videoFile!.path);
        _videoController = VideoPlayerController.file(file)
          ..initialize().then((_) {
            setState(() {});
            _videoController?.play();
          });
      }
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null || kIsWeb) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to upload.")),
      );
      setState(() => _isUploading = false);
      return;
    }

    try {
      final file = File(_videoFile!.path);
      final downloadUrl = await uploadVideoFile(user.uid, file);

      if (downloadUrl == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Upload failed')),
        );
        setState(() => _isUploading = false);
        return;
      }

      await FirebaseFirestore.instance.collection('videos').add({
        'videoUrl': downloadUrl,
        'likes': [],
        'timestamp': FieldValue.serverTimestamp(),
        'uid': user.uid,
      });

      setState(() {
        _isUploading = false;
        _videoFile = null;
        _videoController?.dispose();
        _videoController = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Video uploaded successfully!')),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Upload failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Upload Video'), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _videoFile == null
                ? GestureDetector(
                    onTap: _pickVideo,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(
                        child: Text(
                          'Tap to pick a video',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      AspectRatio(
                        aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
                        child: VideoPlayer(_videoController!),
                      ),
                      const SizedBox(height: 10),
                      _isUploading
                          ? const LinearProgressIndicator()
                          : ElevatedButton(
                              onPressed: _uploadVideo,
                              child: const Text('Upload to GAMMER'),
                            ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
