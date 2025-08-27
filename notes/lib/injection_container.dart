import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/notes/data/datasources/notes_remote_data_source.dart';
import 'features/notes/data/repositories/note_repository_impl.dart';
import 'features/notes/domain/repositories/note_repository.dart';
import 'features/notes/domain/usecases/usecases.dart';
import 'features/notes/presentation/controllers/notes_controller.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Simple manual DI registry
  late final NotesRemoteDataSource _notesRemote;
  late final NoteRepository _noteRepository;
  late final WatchNotes watchNotes;
  late final CreateNote createNote;
  late final DeleteNote deleteNote;
  late final UpdateNoteText updateNoteText;
  late final UpdateNotePinStatus updateNotePinStatus;
  late final NotesController notesController;

  void init() {
    _notesRemote = NotesRemoteDataSourceFirebase(FirebaseFirestore.instance);
    _noteRepository = NoteRepositoryImpl(_notesRemote);
    watchNotes = WatchNotes(_noteRepository);
    createNote = CreateNote(_noteRepository);
    deleteNote = DeleteNote(_noteRepository);
    updateNoteText = UpdateNoteText(_noteRepository);
    updateNotePinStatus = UpdateNotePinStatus(_noteRepository);
    notesController = NotesController(
      watchNotes: watchNotes,
      createNote: createNote,
      deleteNote: deleteNote,
      updateNoteText: updateNoteText,
      updateNotePinStatus: updateNotePinStatus,
    );
  }
}


