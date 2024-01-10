import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_service.dart';

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
          const Text("We've send you an email verification. Please open it to verify your account."),
          const Text("If you haven't received a verification email yet, press the button below."),
          TextButton(onPressed: () async{
            final user = AuthService.firebase().currentUser;
            if(user != null && !user.isEmailVerified){
              await AuthService.firebase().sendEmailVerification();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verification email sent! Check your mail inbox!")));
            }
            
          }, child: const Text('Send email verification')),
          TextButton(onPressed: () async {
            await AuthService.firebase().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          }, child: const Text("Restart"),),
        ]),
    );
  }
}
