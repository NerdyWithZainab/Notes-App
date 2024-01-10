import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/show_error_dialog.dart';

import '../utils/authentication.dart';
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
      AuthService.firebase().createUser(email: email, password: password);
          final user = AuthService.firebase().currentUser;
          AuthService.firebase().sendEmailVerification();
      Navigator.of(context).pushNamed(verifyEmailRoute);
    } on WeakPasswordAuthException{
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The password provided is too weak.'),
          ),
        );
    } on EmailAlreadyInUseAuthException{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('An account already exists with this email.')));
      } on InvalidEmailAuthException{
        await showErrorDialog(context, "This is an invalid email address.");
      }
      on GenericAuthException{
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to register. Please try again later.')));
      }
  }

  Future<void> _registerWithGoogle() async {
    final user = await Authentication.signInWithGoogle(context: context);
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
                      onPressed: _registerWithGoogle,
                      child: const Text("Register with Google"),
                    ),
                    TextButton(onPressed: (){
                       Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                    }, child: const Text("Already registered? Login here!"))
                  ],
                ),
    );
  }
}
