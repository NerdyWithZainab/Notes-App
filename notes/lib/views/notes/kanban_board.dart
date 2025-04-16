import 'package:flutter/material.dart';
import 'package:notes/services/cloud/cloud_note.dart';

class KanbanBoardScreen extends StatelessWidget {
  final VoidCallback onTap;

  const KanbanBoardScreen(
      {super.key, required this.onTap, required List<CloudNote> notes});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // semi-transparent
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.dashboard_customize, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Create Kanban Board",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
