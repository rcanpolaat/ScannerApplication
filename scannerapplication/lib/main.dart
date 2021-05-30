import 'package:flutter/material.dart';
import 'package:scannerapplication/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';

//void main() => runApp(MyApp());
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Scanner Application",
      theme: ThemeData(primarySwatch: Colors.purple, fontFamily: "MarcellusSC"),
      home: LoginPage(),
    );
  }
}
