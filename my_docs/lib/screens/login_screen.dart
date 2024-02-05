import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_docs/colors.dart';
import 'package:my_docs/repo/auth_repository.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessanger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel =
        await ref.watch(authRepositoryProvider).signInWithGoogle();
    if (errorModel.error == null) {
      // Everything was succccessful
      ref.read(userProvider.notifier).update(
            (state) => errorModel.data,
          );
      // navigator.push(
      //   MaterialPageRoute(
      //     builder: (context) => const HomeScreen(),
      //   ),
      // );
      navigator.push('/');
    } else {
      sMessanger.showSnackBar(
        const SnackBar(
          content: Text("An Error occured while signing you in"),
        ),
      );
    }
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

            signInWithGoogle(ref, context);
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
            foregroundColor: Colors.white,
            minimumSize: const Size(
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
