import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_docs/colors.dart';
import 'package:my_docs/repo/auth_repository.dart';
import 'package:my_docs/repo/document_repository.dart';
import 'package:my_docs/widgets/loader.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).logOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);
    if (errorModel.data != null) {
      navigator.push("/document/${errorModel.data.id}");
    } else {
      snackbar.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  void navigateToDocument(BuildContext context, String id){
    final navigator = Routemaster.of(context);

    navigator.push('/document/$id');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String token = ref.read(userProvider)!.token;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: Icon(Icons.add,color: kBlackColor),
          ),
          IconButton(
            onPressed: () {
              signOut(ref);
            },
            icon: Icon(Icons.logout, color: kRedColor),
          ),
        ],
      ),
      body: FutureBuilder(future: ref.read(documentRepositoryProvider).getAllDocuments(token), builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Loader();
        }
        return Center(
          child: Container(
            margin: const EdgeInsets.only(top: 15),
            width: max(MediaQuery.of(context).size.width * 0.4,300),
            child: ListView.builder(
              itemCount: snapshot.data!.data.length,
              itemBuilder: (context, index) {
                final currDocument = snapshot.data!.data[index];
              return SizedBox(
                height: 50,
                child: InkWell(
                  onTap: (){
                    print(currDocument.id);
                    navigateToDocument(context, currDocument.id);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1.5,
                    child: Center(child: Text(currDocument.title, style: TextStyle(fontSize: 17))),
                  ),
                ),
              );
            },),
          ),
        );
      }),
    );
  }
}
