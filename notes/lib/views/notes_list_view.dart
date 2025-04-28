import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notes/services/cloud/cloud_note.dart'; // Import the CloudNote class
import 'package:notes/utilities/dialogs/delete_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

typedef NoteCallback = void Function(CloudNote);

class NotesListView extends StatefulWidget {
  final List<CloudNote> notes; // Receive notes as input
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  final Function(CloudNote) onPinNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
    required this.onPinNote,
  });

  @override
  _NotesListViewState createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  // Maintain separate language states for each note
  Map<String, String> noteLanguages = {};

  String _translatedText = '';

  // Async function that updates the translated text directly in state
  Future<void> translateText(
      String originalText, String sourceLang, String targetLang) async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:5000/translate'), // Replace with your Flask server URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'text': originalText,
        'source_lang': sourceLang,
        'target_lang': targetLang,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        _translatedText = responseData[
            'translation']; // Updates the state with the translation
      });
    } else {
      setState(() {
        _translatedText =
            'Translation failed: ${response.body}'; // Updates the state with error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<CloudNote> sortedNotes = List.from(widget.notes)
      ..sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(100),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.white.withAlpha(150), width: 1.5),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedNotes.length,
                      itemBuilder: (context, index) {
                        final note = sortedNotes[index];
                        String? sourceLang =
                            noteLanguages[note.documentId]?.split(',')[0];
                        String? targetLang =
                            noteLanguages[note.documentId]?.split(',')[1];

                        return Dismissible(
                          key: Key(note.documentId),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            widget.onDeleteNote(note);
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
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(100),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withAlpha(120), width: 1),
                            ),
                            child: ListTile(
                              onTap: () {
                                widget.onTap(note);
                              },
                              title: Text(
                                note.text,
                                style: const TextStyle(color: Colors.black),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Wrap(
                                spacing: 12,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      note.isPinned
                                          ? Icons.push_pin
                                          : Icons.push_pin_outlined,
                                      color: note.isPinned
                                          ? Colors.yellow
                                          : Colors.white,
                                    ),
                                    onPressed: () {
                                      widget.onPinNote(note.copyWith(
                                          isPinned: !note.isPinned));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.translate,
                                        color: Colors.white),
                                    onPressed: () {
                                      translateText(
                                          note.text,
                                          sourceLang ?? 'English',
                                          targetLang ?? 'French');
                                    },
                                  ),
                                  // Dropdown for language selection inside each note
                                  DropdownButton<String>(
                                    value: sourceLang,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        noteLanguages[note.documentId] =
                                            '$newValue,${targetLang ?? 'French'}';
                                      });
                                    },
                                    items: <String>[
                                      'English',
                                      'French',
                                      'Spanish',
                                      'German'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  DropdownButton<String>(
                                    value: targetLang,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        noteLanguages[note.documentId] =
                                            '${sourceLang ?? 'English'},$newValue';
                                      });
                                    },
                                    items: <String>[
                                      'English',
                                      'French',
                                      'Spanish',
                                      'German'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
