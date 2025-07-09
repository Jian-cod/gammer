import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Returns current user's UID
  static String currentUserId() {
    final user = _auth.currentUser;
    return user?.uid ?? '';
  }

  /// Send a DM request (from → to)
  static Future<void> sendDmRequest(String toUserId) async {
    final fromUserId = currentUserId();
    if (fromUserId == toUserId) return;

    final existing = await _db
        .collection('dmRequests')
        .where('from', isEqualTo: fromUserId)
        .where('to', isEqualTo: toUserId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existing.docs.isEmpty) {
      await _db.collection('dmRequests').add({
        'from': fromUserId,
        'to': toUserId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Accept or reject a DM request
  static Future<void> respondDmRequest(String requestId, bool accept) async {
    final status = accept ? 'accepted' : 'rejected';
    await _db.collection('dmRequests').doc(requestId).update({
      'status': status,
    });
  }

  /// Create or get chat ID for two users
  static Future<String> openChat(Set<String> userIds, bool createIfNotExists) async {
    final usersList = userIds.toList()..sort(); // Consistent ordering

    final existing = await _db
        .collection('chats')
        .where('users', isEqualTo: usersList)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    if (!createIfNotExists) throw Exception("Chat not found");

    final chatDoc = await _db.collection('chats').add({
      'users': usersList,
      'lastMessage': '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    return chatDoc.id;
  }
}
