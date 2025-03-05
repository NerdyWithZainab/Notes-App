import 'package:flutter/material.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/utilities/dialogs/delete_dialog.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

typedef NoteCallback = void Function(CloudNote);

class NotesListView extends StatefulWidget {
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
  NotesListViewState createState() => NotesListViewState();
}

class NotesListViewState extends State<NotesListView> {
  List<String> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  // Fetch the list of folders
  Future<void> _loadFolders() async {
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

  // Create a new folder
  Future<void> _createFolder(String folderName) async {
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

  @override
  Widget build(BuildContext context) {
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
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Add button to create a folder
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

                  // Display folders
                  _folders.isEmpty
                      ? const Text("No folders available",
                          style: TextStyle(color: Colors.white))
                      : SizedBox(
                          height: 100, // Limit folder list height
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _folders.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  // Implement folder selection logic here
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
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                  const Divider(color: Colors.white),

                  // Notes list
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: widget.notes.map((note) {
                          return Dismissible(
                            key: Key(note.id.toString()),
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
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
