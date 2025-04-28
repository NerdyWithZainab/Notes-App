import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_storage_constants.dart';
import 'package:notes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final CollectionReference<Map<String, dynamic>> notes =
      FirebaseFirestore.instance.collection('notes');

  // Singleton instance
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  // ✅ Delete Note
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  // ✅ Update Note Text
  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({
        textFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  // ✅ Get all Notes for a User (Sorted by isPinned)
  Stream<Iterable<CloudNote>>? allNotes({required String ownerUserId}) {
    return notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((snapshot) {
      final notesIterable =
          snapshot.docs.map((doc) => CloudNote.fromSnapshot(doc));

      // Sort pinned notes first
      // Sorting in an Iterable-friendly way
      return notesIterable.toList()
        ..sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));
    });
  }

  // ✅ Update Pinned Status of a Note
  Future<void> updateNotePinStatus({
    required String documentId,
    required bool isPinned,
  }) async {
    try {
      await notes.doc(documentId).update({
        'isPinned': isPinned,
      });
    } catch (e) {
      throw Exception("Could not update pin status: $e");
    }
  }

  // ✅ Create a New Note
  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    try {
      final document = await notes.add({
        ownerUserIdFieldName: ownerUserId,
        textFieldName: '',
        'isPinned': false, // Ensure it has a default value
      });

      final fetchedNote = await document.get();
      return CloudNote.fromSnapshot(fetchedNote);
    } catch (e) {
      throw Exception("Could not create new note: $e");
    }
  }
}
