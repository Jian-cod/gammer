import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static String currentUserId() => FirebaseAuth.instance.currentUser!.uid;

  // Follow a user
  static Future<void> follow(String targetId) async {
    final uid = currentUserId();
    final userRef = _db.collection('users').doc(uid);
    final targetRef = _db.collection('users').doc(targetId);
    await userRef.update({'following': FieldValue.arrayUnion([targetId])});
    await targetRef.update({'followers': FieldValue.arrayUnion([uid])});
  }

  // Send DM request
  static Future<void> sendDmRequest(String toId) async {
    final from = currentUserId();
    await _db.collection('dmRequests').doc(const Uuid().v4()).set({
      'from': from,
      'to': toId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> respondDmRequest(String id, bool accept) async {
    await _db.collection('dmRequests').doc(id)
      .update({'status': accept ? 'accepted' : 'rejected'});
  }

  // Open chat (1-on-1 or group)
  static Future<String> openChat(Set<String> members, bool isGroup) async {
    final uid = currentUserId();
    // For 1-on-1, try find existing one
    if (!isGroup) {
      final q = await _db.collection('chats')
        .where('isGroup', isEqualTo: false)
        .where('members', arrayContains: uid).get();
      for (final doc in q.docs) {
        final mems = Set<String>.from(doc['members']);
        if (mems.containsAll(members)) return doc.id;
      }
    }
    final ref = await _db.collection('chats').add({
      'members': members.toList(),
      'isGroup': isGroup,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Stream<QuerySnapshot> fetchChats() {
    final uid = currentUserId();
    return _db.collection('chats').where('members', arrayContains: uid).snapshots();
  }

  static Stream<QuerySnapshot> fetchMessages(String chatId) {
    return _db.collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots();
  }

  static Future<void> sendMessage(String chatId, String text) async {
    await _db.collection('chats/$chatId/messages').add({
      'from': currentUserId(),
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
