// This displays the Login screen for authentication
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';
import '../utils/authentication.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _obscureText = true;

  Future<void> _signInWithGoogle() async {
    final user = await Authentication.signInWithGoogle(context: context);
    if (user != null) {
      // ignore: use_build_context_synchronously
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
      appBar: AppBar(title: const Text("Login")),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration:
                const InputDecoration(hintText: 'Enter your email here'),
          ),
          TextField(
            controller: _password,
            obscureText: _obscureText,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
                hintText: 'Enter your password here',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        _obscureText = !_obscureText;
                      },
                    );
                  },
                )),
          ),
          TextButton(
            onPressed: _signInWithEmailAndPassword,
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: _signInWithGoogle,
            child: const Text("Login with Google"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Not registered yet? Register here!'),
          )
        ],
      ),
    );
  }

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

  // Signing in the user
  Future<void> _signInWithEmailAndPassword() async {
    final email = _email.text;
    final password = _password.text;
    try {
      await AuthService.firebase().logIn(email: email, password: password);
      final user = AuthService.firebase().currentUser;
      if (user?.isEmailVerified ?? false) {
        // User's email is verified
        Navigator.of(context).pushNamedAndRemoveUntil(
          notesRoute,
          (route) => false,
        );
      } else {
        // user's email is NOT verified
        Navigator.of(context).pushNamedAndRemoveUntil(
          verifyEmailRoute,
          (route) => false,
        );
      }
    } on EmailAlreadyInUseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An account already exists with this email.')));
    } on UserNotFoundAuthException {
      await showErrorDialog(context, 'User not found');
    } on WeakPasswordAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The password provided is too weak.')));
    } on WrongPasswordAuthException {
      await showErrorDialog(context, "Wrong Credentials.Please try again.");
    } on GenericAuthException {
      const Text("Authentication Error!");
    }
  }
}
