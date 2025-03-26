import 'package:cloud_firestore/cloud_firestore.dart';

class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final bool isPinned;

  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    required this.isPinned,
  });

  // Factory constructor to safely handle missing fields
  factory CloudNote.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    if (data == null) {
      throw Exception("CloudNote: Document data is null");
    }

    return CloudNote(
      documentId: snapshot.id,
      ownerUserId: data['ownerUserId'] ?? '',
      text: data['text'] ?? '',
      isPinned:
          (data['isPinned'] as bool?) ?? false, // Ensure safe type conversion
    );
  }

  // Convert to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'ownerUserId': ownerUserId,
      'text': text,
      'isPinned': isPinned,
    };
  }
}
