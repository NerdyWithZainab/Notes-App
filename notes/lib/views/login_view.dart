import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final bool _isLoggingIn = false;
  bool _obscureText = true;

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
    final user =
        await Authentication.signInWithGoogle(context: context as BuildContext);
    if (user != null) {
      showDialog(
        context: context as BuildContext,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Login Successful'),
            content: Text('You have successfully logged in.'),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content:
              Text('Failed to sign in with Google. Please try again later.')));
    }
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
          // Black background
          body: Stack(
            children: [
              // Background with subtle pattern
              Container(
                decoration: const BoxDecoration(
                  // Black background with subtle gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 25, 25, 25),
                    ],
                  ),
                ),
                child: Opacity(
                  opacity: 0.3,
                  child: GridPattern(),
                ),
              ),

              // Main content with glassmorphism
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  // Enhanced glassmorphism container
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.fromRGBO(255, 255, 255, .25),
                              Color.fromRGBO(255, 255, 255, .15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: const Color.fromRGBO(255, 255, 255, 0.4),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(255, 255, 255, 0.05),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        // Add internal padding for content
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          // Your original content
                          child: Theme(
                            data: ThemeData(
                              inputDecorationTheme: const InputDecorationTheme(
                                  errorStyle: TextStyle(color: Colors.red)),
                            ),
                            child: Column(children: [
                              Expanded(
                                flex: 2,
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
                              Expanded(
                                flex: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft:
                                        Radius.circular(_isLoggingIn ? 0 : 30),
                                    topRight:
                                        Radius.circular(_isLoggingIn ? 0 : 30),
                                    bottomLeft: const Radius.circular(30),
                                    bottomRight: const Radius.circular(30),
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10.0, sigmaY: 10.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color.fromRGBO(255, 255, 255, 0.35),
                                            Color.fromRGBO(255, 255, 255, 0.25),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              _isLoggingIn ? 0 : 30),
                                          topRight: Radius.circular(
                                              _isLoggingIn ? 0 : 30),
                                          bottomLeft: const Radius.circular(30),
                                          bottomRight:
                                              const Radius.circular(30),
                                        ),
                                        border: Border.all(
                                          color: const Color.fromRGBO(
                                              255, 255, 255, 0.5),
                                          width: 1.0,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                255, 255, 255, 0.05),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 30.0,
                                          vertical: 30.0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Login your account",
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(
                                              height: 25,
                                            ),
                                            TextField(
                                              controller: _email,
                                              enableSuggestions: false,
                                              autocorrect: false,
                                              autofocus: true,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              textInputAction:
                                                  TextInputAction.next,
                                              style: const TextStyle(
                                                  color: Colors.black87),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: const Color.fromRGBO(
                                                    255, 255, 255, 0.7),
                                                hintText: context.loc
                                                    .email_text_field_placeholder,
                                                hintStyle: const TextStyle(
                                                    color: Colors.black54),
                                                errorText: _emailError,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        255, 255, 255, 0.7),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                prefixIcon: const Icon(
                                                    Icons.email_outlined,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TextField(
                                              controller: _password,
                                              obscureText: _obscureText,
                                              enableSuggestions: false,
                                              autocorrect: false,
                                              textInputAction:
                                                  TextInputAction.done,
                                              style: const TextStyle(
                                                  color: Colors.black87),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: const Color.fromRGBO(
                                                    255, 255, 255, 0.7),
                                                errorText: _passwordError,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        255, 255, 255, 0.7),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                hintStyle: const TextStyle(
                                                    color: Colors.black54),
                                                hintText: context.loc
                                                    .password_text_field_placeholder,
                                                prefixIcon: const Icon(
                                                    Icons.lock_outline,
                                                    color: Colors.black54),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscureText
                                                        ? Icons
                                                            .visibility_outlined
                                                        : Icons
                                                            .visibility_off_outlined,
                                                    color: Colors.black54,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscureText =
                                                          !_obscureText;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 25),
                                            Center(
                                              child: Column(
                                                children: [
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.black,
                                                      backgroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 40,
                                                        vertical: 15,
                                                      ),
                                                      elevation: 3,
                                                      shadowColor:
                                                          const Color.fromRGBO(
                                                              255,
                                                              255,
                                                              255,
                                                              0.3),
                                                    ),
                                                    onPressed:
                                                        _signInWithEmailAndPassword,
                                                    child: Text(
                                                      context.loc.login,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 15),
                                                  ElevatedButton.icon(
                                                    icon: const Icon(
                                                        Icons.g_mobiledata,
                                                        size: 24),
                                                    label: const Text(
                                                      "Login with Google",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.black87,
                                                      backgroundColor:
                                                          const Color.fromRGBO(
                                                              255,
                                                              255,
                                                              255,
                                                              0.9),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 40,
                                                        vertical: 15,
                                                      ),
                                                      elevation: 3,
                                                      shadowColor:
                                                          const Color.fromRGBO(
                                                              255,
                                                              255,
                                                              255,
                                                              0.2),
                                                    ),
                                                    onPressed:
                                                        _signInWithGoogle,
                                                  ),
                                                  const SizedBox(height: 15),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Flexible(
                                                        child: TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                          onPressed: () {
                                                            context
                                                                .read<
                                                                    AuthBloc>()
                                                                .add(
                                                                  const AuthEventForgotPassword(
                                                                      email:
                                                                          ''),
                                                                );
                                                          },
                                                          child: Text(
                                                            context.loc
                                                                .forgot_password,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Flexible(
                                                        child: TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                          onPressed: () {
                                                            context
                                                                .read<
                                                                    AuthBloc>()
                                                                .add(
                                                                  const AuthEventShouldRegister(),
                                                                );
                                                          },
                                                          child: Text(
                                                            context.loc
                                                                .login_view_not_registered_yet,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// Custom widget to create a grid pattern for the background
// This enhances the glassmorphism effect by providing something to blur
class GridPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(),
      size: Size.infinite,
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
