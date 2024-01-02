import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/register_view.dart';
import 'package:notes/views/verify_email_view.dart';
import 'firebase_options.dart';

void main() {
  // Initializing the application
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: "Home Page",
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const HomePage(),
    routes: {
      '/login/': ((context) => const LoginView()),
      '/register/': ((context) => const RegisterView())
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
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if(user.emailVerified){
                return const VerifyEmailView();
              }
               return const NotesView();
            } else {
              return const LoginView();
            }   
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main UI'),),
      body: const Text('Hello World'),
    );
  }
}