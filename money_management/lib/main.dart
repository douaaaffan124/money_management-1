import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(MoneyTransferApp());
}

class MoneyTransferApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Transfer App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), 
    );
  }
}
