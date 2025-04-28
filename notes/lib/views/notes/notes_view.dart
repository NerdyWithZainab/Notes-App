import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/enums/menu_action.dart';
import 'package:notes/extensions/buildcontext/loc.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/cloud/firebase_cloud_storage.dart';
import 'package:notes/utilities/dialogs/logout_dialog.dart';
import 'package:notes/views/login_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/views/notes/kanban_board.dart';
import 'package:notes/calender/calendar_screen.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/views/notes_list_view.dart';

Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return null; // User canceled sign-in
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print('Google Sign-In Error: $e');
    return null;
  }
}

extension Count<T extends Iterable<dynamic>> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String? _userId;
// Create a Kanban Board feature
  Future<void> _openKanbanView() async {
    if (_userId == null) return;
    final notesSnapshot =
        await _notesService.allNotes(ownerUserId: _userId!)!.first;
    final notes = notesSnapshot.toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => KanbanBoardScreen(
          notes: notes,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(loginRoute);
      });
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showLogOutDialog(context);
    if (shouldLogout) {
      await AuthService.firebase().logOut();
      await GoogleSignIn().signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Center(
          child: _userId == null
              ? const Text('')
              : StreamBuilder<int>(
                  stream:
                      _notesService.allNotes(ownerUserId: _userId!)?.getLength,
                  builder: (context, snapshot) {
                    final noteCount = snapshot.data ?? 0;
                    return Text(
                      context.loc.notes_title(noteCount),
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                ),
        ),
        backgroundColor: Colors.deepPurple.shade600,
        actions: [
          PopupMenuButton<MenuAction>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == MenuAction.logout) {
                await _handleLogout();
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text(context.loc.logout_button),
                )
              ];
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CalendarScreen()),
          );
        },
        backgroundColor: Colors.deepPurple.shade600,
        child: const Icon(Icons.calendar_today),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.deepPurple.shade600,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/folders');
                },
                color: Colors.white60,
                icon: const Icon(
                  Icons.folder,
                  size: 30,
                ),
              ),
              IconButton(
                onPressed: _openKanbanView,
                color: Colors.white60,
                icon: const Icon(
                  Icons.view_kanban,
                  size: 30,
                ),
              ),
              const SizedBox(width: 48), // Space for FAB
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                },
                color: Colors.white60,
                icon: const Icon(
                  Icons.note_alt,
                  size: 30,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Add another action here if needed
                },
                color: Colors.white60,
                icon: const Icon(
                  Icons.settings,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<Iterable<CloudNote>>(
              stream: _notesService.allNotes(ownerUserId: _userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    final allNotes = snapshot.data!.toList();
                    return NotesListView(
                      notes: allNotes,
                      onDeleteNote: (note) async {
                        await _notesService.deleteNote(
                          documentId: note.documentId,
                        );
                      },
                      onTap: (note) {
                        Navigator.of(context).pushNamed(
                          createOrUpdateNoteRoute,
                          arguments: note,
                        );
                      },
                      onPinNote: (note) async {
                        await _notesService.updateNotePinStatus(
                          documentId: note.documentId,
                          isPinned: !note.isPinned, // Toggle pin status
                        );
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
