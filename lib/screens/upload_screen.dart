import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _videoFile;
  VideoPlayerController? _videoController;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final picker = ImagePicker();

  Future<void> _pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _videoFile = File(pickedFile.path);
      _videoController = VideoPlayerController.file(_videoFile!)
        ..initialize().then((_) {
          setState(() {});
          _videoController?.play();
        });
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to upload.")),
        );
        return;
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final ref = FirebaseStorage.instance.ref().child('videos/$fileName');
      final uploadTask = ref.putFile(_videoFile!);

      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          _uploadProgress = event.bytesTransferred / event.totalBytes;
        });
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Store video info in Firestore
      await FirebaseFirestore.instance.collection('videos').add({
        'videoUrl': downloadUrl,
        'likes': [],
        'timestamp': FieldValue.serverTimestamp(),
        'uid': user.uid,
      });

      setState(() {
        _isUploading = false;
        _videoFile = null;
        _uploadProgress = 0.0;
        _videoController?.dispose();
        _videoController = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Video uploaded successfully!')),
      );
    } catch (e) {
      setState(() => _isUploading = false);
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
      appBar: AppBar(
        title: const Text('Upload Video'),
        backgroundColor: Colors.black,
      ),
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
                          ? LinearProgressIndicator(value: _uploadProgress)
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
