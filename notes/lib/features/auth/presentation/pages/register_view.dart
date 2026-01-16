import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/extensions/buildcontext/loc.dart';
import 'package:notes/features/auth/data/auth/auth_exceptions.dart';
import 'package:notes/features/auth/data/auth/bloc/auth_bloc.dart';
import 'package:notes/features/auth/data/auth/bloc/auth_event.dart';
import 'package:notes/features/auth/data/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';
import 'package:path/path.dart';
import '../../../../../../../utils/authentication.dart';

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
                              Color.fromRGBO(255, 255, 255, 0.25),
                              Color.fromRGBO(255, 255, 255, 0.15),
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
                                    topLeft: Radius.circular(
                                        _isRegisteringIn ? 0 : 30),
                                    topRight: Radius.circular(
                                        _isRegisteringIn ? 0 : 30),
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
                                              _isRegisteringIn ? 0 : 30),
                                          topRight: Radius.circular(
                                              _isRegisteringIn ? 0 : 30),
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
                                              context.loc.register_view_prompt,
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
                                              height: 20,
                                            ),
                                            TextField(
                                              controller: _password,
                                              obscureText: true,
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
                                                    onPressed: () async {
                                                      final email = _email.text;
                                                      final password =
                                                          _password.text;
                                                      context
                                                          .read<AuthBloc>()
                                                          .add(
                                                              AuthEventRegister(
                                                            email: email,
                                                            password: password,
                                                          ));
                                                    },
                                                    child: Text(
                                                      context.loc.register,
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
                                                      "Register with Google",
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
                                                        _registerWithGoogle,
                                                  ),
                                                  const SizedBox(height: 15),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      context.read<AuthBloc>().add(
                                                          const AuthEventLogOut());
                                                    },
                                                    child: Text(
                                                      context.loc
                                                          .register_view_already_registered,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
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
