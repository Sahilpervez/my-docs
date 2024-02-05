import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_docs/models/error_model.dart';
import 'package:my_docs/repo/auth_repository.dart';
import 'package:my_docs/router.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  ErrorModel? errorModel;

  @override
  void initState() {
    super.initState();
    // Everytime the app restarts we want to check the token and user
    // and get the user data from the server so we user getUserData() method
    getUserData();
  }

  Future<void> getUserData() async {
    // get data from the server
    errorModel = await ref.read(authRepositoryProvider).getUserData();

    // if the response form server is not null and has user data then
    // we update our current userProvider
    // print("Error Model : ${errorModel?.data}");
    if (errorModel != null && errorModel!.data != null) {
      ref.read(userProvider.notifier).update((state) => errorModel!.data);
      // if (kDebugMode) {
      //   print("User Updated");
      // }
      // print(ref.read(userProvider)?.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My-Docs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: false,
      ),
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (context) {
          final user = ref.watch(userProvider);
          // user is logged in
          if(user != null && user.token.isNotEmpty){
            return loggedInRoute;
          }
          return loggedOutRoute;
        },
      ),
    );
  }
}
