import 'package:dues/pages/HomePage.dart';
import 'package:dues/pages/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth auth = FirebaseAuth.instance;
  try {
    if (auth.currentUser != null) {
      auth.currentUser!.reload();
    }
  } on Exception catch (e) {
    print(e.toString());
  }
  auth.authStateChanges().listen((User? user) {
    if (auth.currentUser == null || user == null) {
      runApp(const LoginPage());
    } else {
      runApp(const HomePage());
    }
  });
}
