import 'package:flutter/material.dart';
import 'package:notes/config.dart';
import 'package:notes/utilities/dialogs/delete_dialog.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

typedef NoteCallback = void Function(CloudNote);

class CloudNote {
  final String id;
  final String text;
  final bool isPinned;

  CloudNote({
    required this.id,
    required this.text,
    this.isPinned = false,
  });

  get documentId => null;

  CloudNote copyWith({bool? isPinned}) {
    return CloudNote(
      id: id,
      text: text,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

// Function to translate a note's text using a Flask server
Future<String?> translateText(String originalText) async {
  try {
    final response = await http.post(
      Uri.parse(translateEndpoint), // Change this
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': originalText}),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['translated_text'];
    } else {
      print("Translation failed: ${response.statusCode}");
    }
  } catch (e) {
    print("Error during translation: $e");
  }
  return null;
}

class NotesListView extends StatefulWidget {
  final List<CloudNote> notes;
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
  NotesListViewState createState() => NotesListViewState();
}

class NotesListViewState extends State<NotesListView> {
  List<String> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _folders = prefs.getStringList('folders') ?? [];
      });
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = Directory('${directory.path}/NotesFolders');

      if (await folderPath.exists()) {
        setState(() {
          _folders = folderPath
              .listSync()
              .whereType<Directory>()
              .map((dir) => dir.path.split('/').last)
              .toList();
        });
      } else {
        await folderPath.create();
      }
    }
  }

  Future<void> _createFolder(String folderName) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> folders = prefs.getStringList('folders') ?? [];

      if (!folders.contains(folderName)) {
        folders.add(folderName);
        await prefs.setStringList('folders', folders);
        setState(() => _folders = folders);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Folder "$folderName" created!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Folder "$folderName" already exists!')),
        );
      }
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final newFolder = Directory('${directory.path}/NotesFolders/$folderName');

      if (await newFolder.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Folder "$folderName" already exists!')),
        );
      } else {
        await newFolder.create();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Folder "$folderName" created!')),
        );
        _loadFolders();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<CloudNote> sortedNotes = List.from(widget.notes)
      ..sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              width: 350,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: Colors.deepPurple.shade700),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Folders",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.create_new_folder,
                          color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            String newFolderName = '';
                            return AlertDialog(
                              title: const Text("Create Folder"),
                              content: TextField(
                                onChanged: (value) {
                                  newFolderName = value;
                                },
                                decoration: const InputDecoration(
                                  hintText: "Enter folder name",
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (newFolderName.isNotEmpty) {
                                      _createFolder(newFolderName);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text("Create"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                _folders.isEmpty
                    ? const Text("No folders available",
                        style: TextStyle(color: Colors.white))
                    : SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _folders.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Opened folder: ${_folders[index]}')),
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.folder,
                                        color: Colors.white, size: 40),
                                    Text(
                                      _folders[index],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                const Divider(color: Colors.white),
                Expanded(
                    child: ListView.builder(
                        itemCount: sortedNotes.length,
                        itemBuilder: (context, index) {
                          final note = sortedNotes[index];
                          return Dismissible(
                              key: Key(note.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                widget.onDeleteNote(note);
                              },
                              confirmDismiss: (direction) async {
                                return await showDeleteDialog(context);
                              },
                              background: Container(
                                color: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerRight,
                                child: const Icon(Icons.delete_outline),
                              ),
                              child: ListTile(
                                onTap: () {
                                  widget.onTap(note);
                                },
                                title: Text(
                                  note.text,
                                  style: const TextStyle(color: Colors.white),
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
                                      onPressed: () async {
                                        final translated =
                                            await translateText(note.text);
                                        if (translated != null) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.black,
                                                title: const Text(
                                                    'Translated Text',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                content: Text(translated,
                                                    style: const TextStyle(
                                                        color: Colors.white)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text('Close',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .purpleAccent)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Translation failed!")),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ));
                        }))
              ]),
            ),
          )
        ],
      ),
    );
  }
}
