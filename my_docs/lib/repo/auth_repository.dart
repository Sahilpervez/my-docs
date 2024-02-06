// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:my_docs/constrants.dart';
import 'package:my_docs/models/error_model.dart';
import 'package:my_docs/models/user_model.dart';
import 'package:my_docs/repo/local_storage_repository.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorageRepository: LocalStorageRepository(),
  ),
);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;
  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageRepository localStorageRepository,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error = ErrorModel(
      error: "SomeUnexpected error occured",
      data: null,
    );
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        if (kDebugMode) {
          print("FROM GOOGLE SIGN IN : ");
          print(user.displayName);
          print(user.email);
          print(user.id);
          print(user.serverAuthCode);
        }

        final userAcc = UserModel(
          email: user.email,
          name: user.displayName ?? "",
          uid: "",
          profilePic: user.photoUrl ?? "",
          token: "",
        );

        var res = await _client.post(
          Uri.parse("$host/api/signup"),
          body: userAcc.toJson(),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": "true",
            "Access-Control-Allow-Headers":
                "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale,x-auth-token",
            "Access-Control-Allow-Methods":
                "GET, POST, PUT, PATCH, DELETE, OPTIONS"
          },
          encoding: Encoding.getByName('utf-8'),
        );

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)['user']["_id"],
              token: jsonDecode(res.body)["token"],
            );
            error = ErrorModel(
              error: null,
              data: newUser,
            );
            print(newUser.token);
            _localStorageRepository.setToken(newUser.token);
            break;

          default:
            throw "Some Error Occured";
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
      if (kDebugMode) {
        print(e);
      }
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error = ErrorModel(
      error: "Some unexpeceted Error in getUserData() function",
      data: null,
    );
    try {
      String? token = await _localStorageRepository.getToken();
      print("Inside Auth Repo\ntoken : $token");
      if (token != null) {
        final res = await _client.get(
          Uri.parse('$host/'),
          headers: {
            'Content-type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
        );
        // print(res.statusCode);
        final currUser = jsonDecode(res.body)['user'];
        // print(currUser);
        switch (res.statusCode) {
          case 200:
            final newUser = UserModel(
              email: currUser['email'],
              name: currUser['name'],
              profilePic: currUser['profilePic'],
              token: token,
              uid: currUser["_id"],
            );
            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(token);
            break;
          default:
        }
      }
    } catch (e) {
      print("error inside getUserData in AuthRepo\n:$e");
    }

    return error;
  }

  void logOut() async {
    await _googleSignIn.signOut();
    _localStorageRepository.clearToken();
  }
}
