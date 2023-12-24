// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:my_docs/constrants.dart';
import 'package:my_docs/models/document_model.dart';

import 'package:my_docs/models/error_model.dart';

final documentRepositoryProvider =
    Provider((ref) => DocumentRepository(client: Client()));

class DocumentRepository {
  final Client _client;
  DocumentRepository({
    client,
  }) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    var error = ErrorModel(
      error: "Something Unexpected Occured",
      data: null,
    );
    try {
      // api call initialised
      var res = await _client.post(
        Uri.parse("$host/doc/create"),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        }),
      );
      // api call finished

      // checking the status of the code
      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(res.body),
          );
          break;
        default:
          error = ErrorModel(data: null, error: res.body);
      }
    } catch (e) {
      return ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getAllDocuments( String token ) async {
    var error = ErrorModel(error: "Something Unexpected Occured", data: null);
    try {
      var res = await _client.get(
        Uri.parse('$host/docs/me'),
        headers: {
          'Content-Type' : 'application/json; charset=UTF-8',
          'x-auth-token' : token,
        },
      );
      switch (res.statusCode) {
        case 200:
            List<DocumentModel> documents = [];
            for(int i=0 ;i<jsonDecode(res.body).length; i++){
              documents.add(DocumentModel.fromJson(jsonEncode(jsonDecode(res.body)[i])));
            }
            error = ErrorModel(error: null, data: documents);
          break;
        default:
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
}
