// This displays the Login screen for authentication
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/extensions/buildcontext/loc.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';
import '../utils/authentication.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  String? _emailError;
  String? _passwordError;
  bool _obscureText = true;

  bool _validateFields() {
    bool isValid = true;

    // Resetting error messages
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (_email.text.isEmpty) {
      setState(() {
        _emailError = "Email cannot be empty";
      });
      isValid = false;
    }

    if (_password.text.isEmpty) {
      setState(() {
        _passwordError = "Password cannot be empty";
      });
      isValid = false;
    }

    return isValid;
  }

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_cannot_find_user,
            );
          } else if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_wrong_credentials,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_auth_error,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.login),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  context.loc.login_view_prompt,
                ),
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: context.loc.email_text_field_placeholder,
                    errorText: _emailError,
                  ),
                ),
                TextField(
                  controller: _password,
                  obscureText: _obscureText,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                      hintText: context.loc.password_text_field_placeholder,
                      errorText: _passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                  child: Text(context.loc.login),
                ),
                TextButton(
                  onPressed: _signInWithGoogle,
                  child: const Text("Login with Google"),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventForgotPassword(email: ''),
                        );
                  },
                  child: Text(context.loc.forgot_password),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventShouldRegister(),
                        );
                  },
                  child: Text(
                    context.loc.login_view_not_registered_yet,
                  ),
                )
              ],
            ),
          ),
        ),
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
    context.read<AuthBloc>().add(AuthEventLogIn(email, password));
    if (!_validateFields()) {
      return; // Prevent login attempt if validation fails
    }
  }
}
