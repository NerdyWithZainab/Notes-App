import '../../domain/entities/note.dart';
import '../../domain/usecases/usecases.dart';

class NotesController {
  final WatchNotes watchNotes;
  final CreateNote createNote;
  final DeleteNote deleteNote;
  final UpdateNoteText updateNoteText;
  final UpdateNotePinStatus updateNotePinStatus;

  NotesController({
    required this.watchNotes,
    required this.createNote,
    required this.deleteNote,
    required this.updateNoteText,
    required this.updateNotePinStatus,
  });

  Stream<List<Note>> notesStream(String ownerUserId) => watchNotes(ownerUserId);
  Future<Note> create(String ownerUserId) => createNote(ownerUserId);
  Future<void> delete(String id) => deleteNote(id);
  Future<void> updateText(String id, String text) => updateNoteText(id, text);
  Future<void> setPinned(String id, bool isPinned) =>
      updateNotePinStatus(id, isPinned);
}


