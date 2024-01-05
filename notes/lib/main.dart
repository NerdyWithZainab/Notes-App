import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/register_view.dart';
import 'package:notes/views/verify_email_view.dart';
import 'firebase_options.dart';
import 'dart:developer' as devtools show log;


void main() async {
  // Initializing the application
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: "Home Page",
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const HomePage(),
    routes: {
      '/login/': ((context) => const LoginView()),
      '/register/': ((context) => const RegisterView()),
      '/notes/': ((context) => const NotesView())
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        // Check if Firebase initialization is complete
        if (snapshot.connectionState == ConnectionState.done) {
          final user = FirebaseAuth.instance.currentUser;
          // Check if the user is logged in
          if (user != null) {
            // Check if the email is verified
            if (user.emailVerified) {
              // User is logged in and email is verified
              return const NotesView();
            }
            // User is logged in but email is not verified
            return const VerifyEmailView();
          } else {
            // User is not logged in
            return const LoginView();
          }
        }

        // Show loading indicator while waiting for Firebase to initialize
        return const CircularProgressIndicator();
      },
    );
  }
}

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch(value){      
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                      await FirebaseAuth.instance.signOut();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushNamedAndRemoveUntil('/login/', (_) => false);
                  }
                  devtools.log(shouldLogout.toString());
                  break;
              }
              devtools.log(value.toString());
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: MenuAction.logout, child: Text("Log out"))
              ];
            },
          )
        ],
      ),
      body: const Text('Hello World'),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(context: context, builder: (context){
    return AlertDialog(
      title: const Text("Sign Out") ,
      content: const Text("Are you sure you want to sign out?"),
      actions: [
        TextButton(onPressed: (){Navigator.of(context).pop(false);}, child: const Text('Cancel')),
        TextButton(onPressed: (){Navigator.of(context).pop(true);}, child: const Text('Log Out'))
      ],
    );
  }).then((value) => value ?? false);
}