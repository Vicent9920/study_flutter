import 'package:flutter/material.dart';
import 'package:study_flutter/bean/article_bean.dart';
import 'package:study_flutter/dao/db/database.dart';
import 'package:study_flutter/pages/starred_list_page.dart';
import 'package:study_flutter/utils/date_util.dart';
import 'package:study_flutter/utils/sp_store_util.dart';
import 'package:study_flutter/utils/constant.dart';

class HomePage extends StatefulWidget {
  final ArticleBean article;

  HomePage(this.article);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState(this.article);
  }
}

class _HomePageState extends State<HomePage> {
  ArticleBean article;
  String date = formatDate(DateTime.now());

  _HomePageState(this.article);

  double _fontSize = 18;
  TabController _tabController;
  int _themeColorIndex = 0;

  ArticleProvider provider;

  @override
  void initState() {
    super.initState();
    provider = ArticleProvider();
    getFontSize()
        .then((value) {
          if (value != _fontSize) {
            _fontSize = value;
          }
        })
        .then((value) => getThemeColor())
        .then((value) {
          if (value != _themeColorIndex) {
            setState(() {
              _themeColorIndex = value;
              _tabController.index = value;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(article.data.title),
                centerTitle: true,
                leading:
                    IconButton(icon: Icon(Icons.menu), onPressed: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                            return new StaredListPage();
                          })).then((result) {
                        if (result is ArticleBean) {
                          // Clicked a starred article and back
                          setState(() {
                            article = result;
                            date = article.date;
                          });
                        } else {
                          // Normally back, check current article's starred state
                          provider.getFromDB(article.date).then((articleBean) {
                            if (articleBean != null && articleBean.starred != article.starred) {
                              setState(() => article.starred = articleBean.starred);
                            }
                          });
                        }
                      });
                    }),
                actions: <Widget>[
                  IconButton(
                    icon:
                        Icon(article.starred ? Icons.star : Icons.star_border),
                    onPressed: onStarPressed,
                  )
                ],
                backgroundColor: themeColors[_themeColorIndex],
              )
            ];
          },
          body: new SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: Text.rich(
                        TextSpan(
                          text:
                              "(${getRelatedTime(context, str2Date(article.data.date.curr))}，作者：${article.data.author}，字数：${article.data.wc})",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: _fontSize - 3,
                            height: 1.4,
                          ),
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SingleChildScrollView(
                        child: Text(
                      article?.data?.content,
                      style: TextStyle(fontSize: _fontSize),
                      textAlign: TextAlign.start,
                    ))
                  ],
                ),
                color: Color(0xCCCCCC)),
          )),
    );
  }

  void onStarPressed() {
    setState(() {
      article.starred = !article.starred;
    });
    provider.insertOrReplaceToDB(article);
  }

  void push() {
//    Navigator.pushReplacement(context,
//        MaterialPageRoute(builder: (BuildContext context) {
//      return new StaredListPage();
//    })).then((result) {
//      if (result is ArticleBean) {
//        // Clicked a starred article and back
//        setState(() {
//          article = result;
//          date = article.date;
//        });
//      } else {
//        // Normally back, check current article's starred state
//        provider.getFromDB(article.date).then((articleBean) {
//          if (articleBean != null && articleBean.starred != article.starred) {
//            setState(() => article.starred = articleBean.starred);
//          }
//        });
//      }
//    });

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => StaredListPage()))
        .then((result) {
      if (result is ArticleBean) {
        // Clicked a starred article and back
        setState(() {
          article = result;
          date = article.date;
        });
      } else {
        // Normally back, check current article's starred state
        provider
            .getFromDB(article.date)
            .then((articleBean) {
          if (articleBean != null &&
              articleBean.starred != article.starred) {
            setState(() =>
            article.starred = articleBean.starred);
          }
        });
      }
    });
  }
}
