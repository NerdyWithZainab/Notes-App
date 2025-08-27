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

  CloudNote copyWith({
    String? documentId,
    String? ownerUserId,
    String? text,
    bool? isPinned,
  }) {
    return CloudNote(
      documentId: documentId ?? this.documentId,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      text: text ?? this.text,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
