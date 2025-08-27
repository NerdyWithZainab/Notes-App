import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.ownerUserId,
    required super.text,
    required super.isPinned,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      ownerUserId: map['ownerUserId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      isPinned: map['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerUserId': ownerUserId,
        'text': text,
        'isPinned': isPinned,
      };
}


