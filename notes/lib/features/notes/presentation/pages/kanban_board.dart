import 'package:flutter/material.dart';
import 'package:notes/features/notes/data/models/cloud_note.dart';

class KanbanBoardScreen extends StatefulWidget {
  final List<CloudNote> notes;
  final VoidCallback onTap;
  const KanbanBoardScreen(
      {super.key, required this.notes, required this.onTap});

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  List<String> boardTitles = ['To Do', 'In Progress', 'Done'];
  List<Color> boardColors = [Colors.deepPurple, Colors.teal, Colors.orange];

  void renameBoard(int index) async {
    String currentName = boardTitles[index];
    TextEditingController controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Board'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new board name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                boardTitles[index] = controller.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void addBoard() {
    setState(() {
      boardTitles.add("New Board");
      boardColors.add(Colors.blueGrey); // Add default color
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Kanban Boards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addBoard,
          ),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: boardTitles.length,
        itemBuilder: (context, index) {
          return buildKanbanColumn(
            title: boardTitles[index],
            color: boardColors[index % boardColors.length],
            onRename: () => renameBoard(index),
          );
        },
      ),
    );
  }

  Widget buildKanbanColumn({
    required String title,
    required Color color,
    required VoidCallback onRename,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onRename,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.edit, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => Card(
                color: Colors.white,
                child: ListTile(
                  title: Text('$title Task ${index + 1}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
