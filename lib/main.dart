import 'package:flutter/material.dart';
import 'package:study_flutter/generated/i18n.dart';
import 'package:study_flutter/pages/splash_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '一文',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
//      supportedLocales: [
//        const Locale('en', 'US'), // 美国英语
//        const Locale('zh', 'CN'), // 中文简体
//        //其它Locales
//      ],
      home: SplashPage(title: 'splash'),
    );
  }
}
