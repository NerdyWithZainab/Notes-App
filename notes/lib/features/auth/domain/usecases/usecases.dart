import '../entities/note.dart';
import '../repositories/note_repository.dart';

class WatchNotes {
  final NoteRepository repository;
  WatchNotes(this.repository);
  Stream<List<Note>> call(String ownerUserId) => repository.watchNotes(ownerUserId);
}

class CreateNote {
  final NoteRepository repository;
  CreateNote(this.repository);
  Future<Note> call(String ownerUserId) => repository.createNote(ownerUserId);
}

class DeleteNote {
  final NoteRepository repository;
  DeleteNote(this.repository);
  Future<void> call(String id) => repository.deleteNote(id);
}

class UpdateNoteText {
  final NoteRepository repository;
  UpdateNoteText(this.repository);
  Future<void> call(String id, String text) => repository.updateNoteText(id, text);
}

class UpdateNotePinStatus {
  final NoteRepository repository;
  UpdateNotePinStatus(this.repository);
  Future<void> call(String id, bool isPinned) => repository.updateNotePinStatus(id, isPinned);
}


