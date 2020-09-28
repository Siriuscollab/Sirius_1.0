import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sirius/autenticate.dart';
import 'package:sirius/sign_in.dart';
void main() => runApp(MaterialApp(
  routes: {
    '/': (context) => SignIn(),
    '/signin': (context) => SignIn(),
  },
));
