import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Stream<List<NoteModel>> watchNotes(String ownerUserId);
  Future<NoteModel> createNote(String ownerUserId);
  Future<void> deleteNote(String id);
  Future<void> updateNoteText(String id, String text);
  Future<void> updateNotePinStatus(String id, bool isPinned);
}

class NotesRemoteDataSourceFirebase implements NotesRemoteDataSource {
  final CollectionReference<Map<String, dynamic>> collection;
  NotesRemoteDataSourceFirebase(FirebaseFirestore firestore)
      : collection = firestore.collection('notes');

  @override
  Stream<List<NoteModel>> watchNotes(String ownerUserId) {
    return collection
        .where('ownerUserId', isEqualTo: ownerUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
            .toList())
        .map((list) {
      list.sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));
      return list;
    });
  }

  @override
  Future<NoteModel> createNote(String ownerUserId) async {
    final document = await collection.add({
      'ownerUserId': ownerUserId,
      'text': '',
      'isPinned': false,
    });
    final fetched = await document.get();
    return NoteModel.fromMap(fetched.id, fetched.data() ?? {});
  }

  @override
  Future<void> deleteNote(String id) => collection.doc(id).delete();

  @override
  Future<void> updateNoteText(String id, String text) =>
      collection.doc(id).update({'text': text});

  @override
  Future<void> updateNotePinStatus(String id, bool isPinned) =>
      collection.doc(id).update({'isPinned': isPinned});
}
