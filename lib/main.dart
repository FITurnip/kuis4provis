import 'package:flutter/material.dart';
import 'package:kuis4/auth/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login/Register',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginRegisterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
