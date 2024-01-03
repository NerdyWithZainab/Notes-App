import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email"),),
      body: Column(children: [
          const Text('Please verify your email address:'),
          TextButton(onPressed: () async{
            final user = FirebaseAuth.instance.currentUser;
            if(user != null && !user.emailVerified){
              await user.sendEmailVerification();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verification email sent! Check your mail inbox!")));
            }
            
          }, child: const Text('Send email verification'))
        ]),
    );
  }
}
