import '../entities/note.dart';

abstract class NoteRepository {
  Stream<List<Note>> watchNotes(String ownerUserId);
  Future<Note> createNote(String ownerUserId);
  Future<void> deleteNote(String id);
  Future<void> updateNoteText(String id, String text);
  Future<void> updateNotePinStatus(String id, bool isPinned);
}


