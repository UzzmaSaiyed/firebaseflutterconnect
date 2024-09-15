import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_screen.dart'; // Create a separate file for the main content

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
