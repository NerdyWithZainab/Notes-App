import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/enums/menu_action.dart';
import 'package:notes/extensions/buildcontext/loc.dart';
import 'dart:developer' as devtools show log;

import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/firebase_cloud_storage.dart';
import 'package:notes/utilities/dialogs/logout_dialog.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/notes_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

extension Count<T extends Iterable> on Stream<T> {
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
          child: StreamBuilder(
              stream: _userId == null
                  ? const Stream<int>.empty()
                  : _notesService.allNotes(ownerUserId: _userId!).getLength,
              builder: (context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  final noteCount = snapshot.data ?? 0;
                  final text = context.loc.notes_title(noteCount);
                  return Text(text,
                      style: const TextStyle(color: Colors.white));
                } else {
                  return const Text('');
                }
              }),
        ),
        backgroundColor: Colors.deepPurple.shade600,
        actions: [
          PopupMenuButton<MenuAction>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                    // ignore: use_build_context_synchronously
                  }

                  devtools.log(shouldLogout.toString());
                  break;
              }
              devtools.log(value.toString());
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple.shade600,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed('/folders'); // Navigate to FolderViewScreen
                  },
                  color: Colors.white60,
                  icon: const Icon(
                    Icons.folder,
                    size: 40,
                  )),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                },
                color: Colors.white60,
                icon: const Icon(
                  Icons.note_alt,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: _userId!),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
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
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }

              default:
                return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
