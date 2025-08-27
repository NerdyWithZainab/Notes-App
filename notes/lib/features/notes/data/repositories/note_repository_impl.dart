import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/notes_remote_data_source.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NotesRemoteDataSource remote;
  NoteRepositoryImpl(this.remote);

  @override
  Stream<List<Note>> watchNotes(String ownerUserId) =>
      remote.watchNotes(ownerUserId);

  @override
  Future<Note> createNote(String ownerUserId) => remote.createNote(ownerUserId);

  @override
  Future<void> deleteNote(String id) => remote.deleteNote(id);

  @override
  Future<void> updateNoteText(String id, String text) =>
      remote.updateNoteText(id, text);

  @override
  Future<void> updateNotePinStatus(String id, bool isPinned) =>
      remote.updateNotePinStatus(id, isPinned);
}


