// This displays the Login screen for authentication with glassmorphism effect

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/extensions/buildcontext/loc.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';
import '../utils/authentication.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // Import for BackdropFilter

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
  final bool _isLoggingIn = false;
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
          } else if (state.exception is WrongPasswordAuthException) {
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
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: Container(
          // Add a background image or gradient here if desired
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: SafeArea(
            child: Theme(
              data: ThemeData(
                  inputDecorationTheme: const InputDecorationTheme(
                errorStyle: TextStyle(color: Colors.white),
              )),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                      // Glassmorphism container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 40.0),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Login your account",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    // Inner glassmorphic content area
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 5, sigmaY: 5),
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              TextField(
                                                controller: _email,
                                                enableSuggestions: false,
                                                autocorrect: false,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                textInputAction:
                                                    TextInputAction.next,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white
                                                      .withOpacity(0.1),
                                                  hintText: context.loc
                                                      .email_text_field_placeholder,
                                                  hintStyle: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.7)),
                                                  errorText: _emailError,
                                                  prefixIcon: const Icon(
                                                      Icons.email,
                                                      color: Colors.white70),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                      borderSide:
                                                          BorderSide.none),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.5),
                                                        width: 2.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              TextField(
                                                controller: _password,
                                                obscureText: _obscureText,
                                                enableSuggestions: false,
                                                autocorrect: false,
                                                textInputAction:
                                                    TextInputAction.done,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white
                                                      .withOpacity(0.1),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.5),
                                                        width: 2.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  hintText: context.loc
                                                      .password_text_field_placeholder,
                                                  hintStyle: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.7)),
                                                  errorText: _passwordError,
                                                  prefixIcon: const Icon(
                                                      Icons.lock,
                                                      color: Colors.white70),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _obscureText
                                                          ? Icons.visibility
                                                          : Icons
                                                              .visibility_off,
                                                      color: Colors.white70,
                                                    ),
                                                    onPressed: () {
                                                      setState(
                                                        () {
                                                          _obscureText =
                                                              !_obscureText;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              ElevatedButton(
                                                onPressed:
                                                    _signInWithEmailAndPassword,
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.black,
                                                  backgroundColor: Colors.white
                                                      .withOpacity(0.9),
                                                  minimumSize: const Size(
                                                      double.infinity, 50),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: Text(
                                                  context.loc.login,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      context
                                                          .read<AuthBloc>()
                                                          .add(
                                                            const AuthEventForgotPassword(
                                                                email: ''),
                                                          );
                                                    },
                                                    child: Text(context
                                                        .loc.forgot_password),
                                                  ),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      context
                                                          .read<AuthBloc>()
                                                          .add(
                                                            const AuthEventShouldRegister(),
                                                          );
                                                    },
                                                    child: Text(
                                                      context.loc
                                                          .login_view_not_registered_yet,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "OR",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 15),
                                    ElevatedButton.icon(
                                      onPressed: _signInWithGoogle,
                                      icon: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: Image.asset(
                                          'assets/icon/google.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                      label: const Text("Sign in with Google"),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.9),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 24),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
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
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Signing in the user
  Future<void> _signInWithEmailAndPassword() async {
    if (!_validateFields()) {
      return; // Prevent login attempt if validation fails
    }
    final email = _email.text;
    final password = _password.text;
    context.read<AuthBloc>().add(AuthEventLogIn(email, password));
  }
}
