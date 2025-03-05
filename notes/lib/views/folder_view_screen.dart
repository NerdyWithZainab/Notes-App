import 'package:flutter/material.dart';
import 'package:notes/views/folder_view.dart';

class FolderViewScreen extends StatefulWidget {
  const FolderViewScreen({super.key});

  @override
  _FolderViewScreenState createState() => _FolderViewScreenState();
}

class _FolderViewScreenState extends State<FolderViewScreen> {
  List<String> _folders = [];

  // Fetch the list of folders
  Future<void> _loadFolders() async {
    final folders = await FolderView.listFolders();
    setState(() {
      _folders = folders;
    });
  }

  // Create a new folder
  Future<void> _createFolder(String folderName) async {
    final result = await FolderView.createFolder(folderName);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    _loadFolders();
  }

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Folders"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
      body: _folders.isEmpty
          ? const Center(child: Text("No folders available"))
          : ListView.builder(
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_folders[index]),
                );
              },
            ),
    );
  }
}
