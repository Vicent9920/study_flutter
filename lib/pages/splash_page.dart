import 'package:flutter/material.dart';
import 'package:study_flutter/bean/article_bean.dart';
import 'package:study_flutter/dao/Article.dart';
import 'package:study_flutter/pages/home_page.dart';

class SplashPage extends StatefulWidget{
  SplashPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SplashPageState();
  }

}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    Article.today().then((article) {
      toHome(article);
    }).catchError((e) {
      print(e);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Container(
        child: Image(image: AssetImage('res/images/splash.png'), fit: BoxFit.fill,),
      );
    });
  }

  void toHome(ArticleBean article) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage(article)));
  }
}