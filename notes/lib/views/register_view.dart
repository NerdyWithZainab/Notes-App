import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/extensions/buildcontext/loc.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';
import 'package:path/path.dart';
import '../utils/authentication.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  final bool _isRegisteringIn = false;

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

  Future<void> _registerWithGoogle() async {
    final user =
        await Authentication.signInWithGoogle(context: context as BuildContext);
    if (user != null) {
      showDialog(
        context: context as BuildContext,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Registration Successful'),
            content: Text('You have successfully registered in.'),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content:
              Text('Failed to sign in with Google. Please try again later.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateRegistering) {
            if (state.exception is WeakPasswordAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_weak_password,
              );
            } else if (state.exception is EmailAlreadyInUseAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_email_already_in_use,
              );
            } else if (state.exception is GenericAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_generic,
              );
            } else if (state.exception is InvalidEmailAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_invalid_email,
              );
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Theme(
              data: ThemeData(
                inputDecorationTheme: const InputDecorationTheme(
                    errorStyle: TextStyle(color: Colors.white)),
              ),
              child: Column(children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Capture',
                      style: GoogleFonts.lavishlyYours(
                          textStyle: const TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_isRegisteringIn ? 0 : 30),
                      topRight: Radius.circular(_isRegisteringIn ? 0 : 30),
                      bottomLeft: const Radius.circular(30),
                      bottomRight: const Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60.0,
                      vertical: 60.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.loc.register_view_prompt,
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: _email,
                          enableSuggestions: false,
                          autocorrect: false,
                          autofocus: true,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: context.loc.email_text_field_placeholder,
                            hintStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              hintStyle: const TextStyle(color: Colors.black),
                              hintText:
                                  context.loc.password_text_field_placeholder),
                        ),
                        Center(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final email = _email.text;
                                    final password = _password.text;
                                    context
                                        .read<AuthBloc>()
                                        .add(AuthEventRegister(
                                          email: email,
                                          password: password,
                                        ));
                                  },
                                  child: Text(context.loc.register),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: _registerWithGoogle,
                                child: const Text("Register with Google"),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white),
                                onPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(const AuthEventLogOut());
                                },
                                child: Text(
                                  context.loc.register_view_already_registered,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ]),
            ),
          ),
        ));
  }
}
