import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/authentication.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Registering the user
  Future<void> _registerWithEmailAndPassword() async {
    final email = _email.text;
    final password = _password.text;
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The password provided is too weak.'),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('An account already exists with this email.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to register. Please try again later.')));
    }
  }

  Future<void> _RegisterWithGoogle() async {
    User? user = await Authentication.signInWithGoogle(context: context);
    if (user != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Login Successful'),
            content: Text('You have successfully logged in.'),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Failed to sign in with Google. Please try again later.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: const Text("Register")),
      body: Column(
                  children: [
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          hintText: 'Enter your email here'),
                    ),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                          hintText: 'Enter your password here'),
                    ),
                    TextButton(
                      onPressed: _registerWithEmailAndPassword,
                      child: const Text('Register'),
                    ),
                    TextButton(
                      onPressed: _RegisterWithGoogle,
                      child: const Text("Register with Google"),
                    ),
                    TextButton(onPressed: (){
                       Navigator.of(context).pushNamedAndRemoveUntil('/login/', (route) => false);
                    }, child: const Text("Already registered? Login here!"))
                  ],
                ),
    );
  }
}
