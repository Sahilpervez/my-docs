import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_docs/colors.dart';
import 'package:my_docs/repo/auth_repository.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref){
    ref.watch(authRepositoryProvider).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            if (kDebugMode) {
              print("Sign-In with google pressed");
            }
            // ref.watch(authRepositoryProvider).signInWithGoogle();

            signInWithGoogle(ref);
          },
          icon: const Image(
            image: AssetImage("assets/Icons/google.png"),
            height: 30,
            width: 30,
          ),
          label: const Text(
            "Sign in with Google",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, minimumSize: const Size(
              150,
              50,
            ),
            backgroundColor: kWhiteColor,
            elevation: 10,
          ),
        ),
      ),
    );
  }
}
