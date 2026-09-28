import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore? firestore;

  ChatService({this.firestore});

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messagesRef(String inquiryId) =>
      _db.collection('chats').doc(inquiryId).collection('messages');

  /// Sends a message inside the scoped inquiry chat room.
  Future<void> sendMessage({
    required String inquiryId,
    required String senderId,
    required String text,
  }) async {
    if (inquiryId.isEmpty || text.trim().isEmpty) return;

    final docRef = _messagesRef(inquiryId).doc();
    final message = ChatMessageModel(
      id: docRef.id,
      inquiryId: inquiryId,
      senderId: senderId,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    await docRef.set(message.toMap());

    // Update parent chat document with latest message info
    await _db.collection('chats').doc(inquiryId).set({
      'inquiryId': inquiryId,
      'lastMessage': text.trim(),
      'lastUpdated': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Streams messages scoped to an inquiryId, sorted by createdAt ascending.
  Stream<List<ChatMessageModel>> getMessages(String inquiryId) {
    if (inquiryId.isEmpty) return Stream.value([]);

    return _messagesRef(inquiryId).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return ChatMessageModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }
}
