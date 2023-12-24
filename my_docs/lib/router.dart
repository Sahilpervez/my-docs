import 'package:flutter/material.dart';
import 'package:my_docs/screens/document_screen.dart';
import 'package:my_docs/screens/home_screen.dart';
import 'package:my_docs/screens/login_screen.dart';
import 'package:routemaster/routemaster.dart';

// What should be displayed when the user is not logged in
final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(
  routes: {
    '/': (route) => const MaterialPage(child: HomeScreen()),
    '/document/:id': (route) => MaterialPage(
          child: DocumentScreen(
            id: route.pathParameters['id'] ?? "",
          ),
        ),
  },
);
