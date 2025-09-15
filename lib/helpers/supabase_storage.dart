import 'dart:io';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// Uploads a profile picture to Supabase Storage
/// Returns the public URL if successful
Future<String?> uploadProfilePicture(String userId, File file) async {
  final path = '$userId/avatar.png';

  try {
    await supabase.storage.from('profile-pictures').upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    // Get public URL
    final publicUrl = supabase.storage.from('profile-pictures').getPublicUrl(path);

    debugPrint('✅ Profile picture uploaded: $publicUrl');
    return publicUrl;
  } catch (e) {
    debugPrint('❌ Error uploading profile picture: $e');
    return null;
  }
}
