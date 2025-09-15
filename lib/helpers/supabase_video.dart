import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// Uploads a video file to Supabase and returns the public URL
Future<String?> uploadVideoFile(String userId, File file) async {
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
  final path = 'videos/$userId/$fileName';

  try {
    await supabase.storage.from('videos').upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    // Get public URL
    final publicUrl = supabase.storage.from('videos').getPublicUrl(path);

    debugPrint('✅ Video uploaded: $publicUrl');
    return publicUrl;
  } catch (e) {
    debugPrint('❌ Error uploading video: $e');
    return null;
  }
}
