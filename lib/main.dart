import 'package:flutter/material.dart';
import 'package:monsiegesocial/pages/loginchecker.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Monsiegesocial',
        theme: ThemeData(
          fontFamily: "Sinkin",
        ),
        home: const LoginChecker());
  }
}
