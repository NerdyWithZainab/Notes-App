import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Center(
          child: Container(
            width: 350,
            height: 600,
            decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: Colors.deepPurple.shade700),
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                )),
            child: SingleChildScrollView(
              child: Column(
                  children: notes.map((note) {
                return Dismissible(
                  key: Key(note.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    onDeleteNote(note);
                  },
                  confirmDismiss: (direction) async {
                    return await showDeleteDialog(context);
                  },
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete_outline),
                  ),
                  child: ListTile(
                    onTap: () {
                      onTap(note);
                    },
                    title: Text(
                      note.text,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList()),
            ),
          ),
        ),
      ]),
    );
  }
}
