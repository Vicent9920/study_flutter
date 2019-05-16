import 'package:flutter/material.dart';
import 'package:study_flutter/pages/splash_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '一文',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: SplashPage(title: 'splash'),
    );
  }
}