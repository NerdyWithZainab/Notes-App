class Note {
  final String id;
  final String ownerUserId;
  final String text;
  final bool isPinned;

  const Note({
    required this.id,
    required this.ownerUserId,
    required this.text,
    required this.isPinned,
  });

  Note copyWith({
    String? id,
    String? ownerUserId,
    String? text,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      text: text ?? this.text,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}


