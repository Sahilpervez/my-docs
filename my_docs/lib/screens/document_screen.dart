import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_docs/colors.dart';
import 'package:my_docs/models/document_model.dart';
import 'package:my_docs/models/error_model.dart';
import 'package:my_docs/repo/auth_repository.dart';
import 'package:my_docs/repo/document_repository.dart';
import 'package:my_docs/repo/socket_repository.dart';
import 'package:my_docs/widgets/loader.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  const DocumentScreen({Key? key, required this.id}) : super(key: key);
  final String id;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final TextEditingController _titleController = TextEditingController(
    text: "Untitled Document",
  );
  quill.QuillController? _quillController;
  ErrorModel? errorModel;

  SocketRepository socketRepo = SocketRepository();

  @override
  void initState() {
    super.initState();
    // if (kDebugMode) {
    // print("inside init state");
    // print("ID = ${widget.id}");
    // }
    socketRepo.joinRoom(widget.id);
    // print("ROOM JOINED!!");
    // print("FETCHING DOCUMENT...");
    fetchCurrentDocument();

    // print("ESTABLISHING CHANGE LISTENER....");
    socketRepo.changeListener(converterFunction: (data) {
      _quillController?.compose(
        Delta.fromJson(data['delta']),
        _quillController?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.remote,
      );
    });
    // print("ESTABLISHED CHANGE LISTENERS...");

    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepo.autoSave(<String, dynamic>{
        'delta': _quillController!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  void fetchCurrentDocument() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);
    if (kDebugMode) {
      print("ERROR: ${errorModel?.error}");
      print("DATA: ${errorModel?.data}");
    }

    if (errorModel!.data != null) {
      _titleController.text = (errorModel!.data as DocumentModel).title;
      // print("INITIALIZING QUILL CONTROLLER...");
      _quillController = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                Delta.fromJson(errorModel!.data.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
      // print("QUILL CONTROLLER INITIALIZED...");
      setState(() {});
    }
    // print("LISTENING TO CHANGES...");
    _quillController!.document.changes.listen((event) {
      if (event.source == quill.ChangeSource.local) {
        Map<String, dynamic> map = {
          'delta': event.change,
          'room': widget.id,
        };
        socketRepo.typing(map);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  void updateTitle(WidgetRef ref, String title) async {
    final res = await ref.read(documentRepositoryProvider).updateTitle(
          token: ref.read(userProvider)!.token,
          title: title,
          id: widget.id,
        );
    if (kDebugMode) {
      print(res.data);
    }
  }

  void goToHome() {
    final navigator = Routemaster.of(context);
    navigator.replace('/');
  }

  @override
  Widget build(BuildContext context) {
    if (_quillController == null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(children: [
            InkWell(
              onTap: () {
                goToHome();
              },
              child: Image.asset(
                "assets/Icons/docs_logo.png",
                height: 40,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _titleController,
                onSubmitted: (value) {
                  updateTitle(ref, value);
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: kBlueColor,
                    ),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ]),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration:
                BoxDecoration(border: Border.all(color: kGreyColor, width: 1)),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: kBlueColor),
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                          text:
                              "https://main--my-docs-2612.netlify.app/#/document/${widget.id}"))
                      .then(
                    (value) => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Link Copied to Clipboard",
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.lock, size: 16),
                label: const Text("Share")),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: quill.QuillToolbar.simple(
                configurations: quill.QuillSimpleToolbarConfigurations(
                    showAlignmentButtons: true,
                    showColorButton: true,
                    showSearchButton: true,
                    controller: _quillController!),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: SizedBox(
                  width: 800,
                  child: Card(
                    color: kWhiteColor,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: quill.QuillEditor.basic(
                        configurations: quill.QuillEditorConfigurations(
                            controller: _quillController!,
                            // readOnly: false,
                            expands: false),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
