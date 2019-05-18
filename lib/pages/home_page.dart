import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_flutter/bean/article_bean.dart';
import 'package:study_flutter/dao/Article.dart';
import 'package:study_flutter/dao/db/database.dart';
import 'package:study_flutter/pages/starred_list_page.dart';
import 'package:study_flutter/utils/constant.dart';
import 'package:study_flutter/utils/date_util.dart';
import 'package:study_flutter/utils/sp_store_util.dart';
import 'package:study_flutter/utils/toast.dart';

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
                leading: IconButton(icon: Icon(Icons.menu), onPressed: push),
                actions: <Widget>[
                  IconButton(
                    icon:
                        Icon(article.starred ? Icons.star : Icons.star_border),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return _showBottomWidget(context);
                          });
                    },
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
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return new FloatingActionButton(
          child: const Icon(Icons.date_range),
          tooltip: "选择日期",
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          heroTag: null,
          onPressed: () {
            selectDate(context);
          },
          shape: new CircleBorder(),
          isExtended: false,
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void onStarPressed() {
    setState(() {
      article.starred = !article.starred;
    });
    provider.insertOrReplaceToDB(article);
  }

  void push() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return new StaredListPage();
    })).then((result) {
      if (result is ArticleBean) {
        setState(() {
          article = result;
          date = article.date;
        });
      } else {
        provider.getFromDB(article.date).then((articleBean) {
          if (articleBean != null && articleBean.starred != article.starred) {
            setState(() => article.starred = articleBean.starred);
          }
        });
      }
    });
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: str2Date(article.date),
        firstDate: DateTime(2015, 8),
        lastDate: str2Date(article.date));
    if (picked != null && picked != article.date) {
      ArticleBean bean = await Article.getArticle(date: formatDate(picked));
      if (bean != null) {
        setState(() {
          article = bean;
          date = bean.date;
        });
      }
    }
  }

  Widget _showBottomWidget(BuildContext context) {
    return new Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      height: 230,
      child: new Column(
        children: <Widget>[
          _getItem(1),
          _getItem(2),
          _getItem(3),
          _getItem(4),
          _getItem(5),
          new Container(
            margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            height: 8,
            color: Colors.blueGrey,
          ),
          new Center(
            child: new Padding(
                padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
                child: new Text(
                  '取  消',
                  style: new TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                )),
          )
        ],
      ),
    );
  }

  /**
   * 抽取item项
   */
  Widget _getItem(int index) {
    TextStyle style = const TextStyle(color: Colors.white);
    if (index & 1 == 1) {
      switch (index) {
        case 1:
          return new Padding(
            padding: EdgeInsets.fromLTRB(36, 0, 36.0, 0),
            child: MaterialButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    article?.starred ? Icons.star : Icons.star_border,
                    color: Colors.white,
                  ),
                  Container(
                    width: 6,
                  ),
                  Text(
                    article?.starred ? "已收藏" : "未收藏",
                    style: style,
                  )
                ],
              ),
              color: Colors.blue,
              onPressed: (){
                onStarPressed();
                Navigator.of(context).pop();
              },
            ),
          );
        case 3:
          return new Padding(
            padding: EdgeInsets.fromLTRB(36, 0, 36.0, 0),
            child: MaterialButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                  Container(
                    width: 6,
                  ),
                  Text(
                    "分享",
                    style: style,
                  )
                ],
              ),
              color: Colors.blue,
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          );
        case 5:
          return new Padding(
            padding: EdgeInsets.fromLTRB(36, 0, 36.0, 0),
            child: MaterialButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.content_copy,
                    color: Colors.white,
                  ),
                  Container(
                    width: 6,
                  ),
                  Text(
                    "复制",
                    style: style,
                  )
                ],
              ),
              color: Colors.blue,
              onPressed: () {
                ClipboardData data = new ClipboardData(
                    text:
                        "(${getRelatedTime(context, str2Date(article.data.date.curr))}，作者：${article.data.author}，字数：${article.data.wc})\n${article?.data.content}");
                Clipboard.setData(data);
                Toast.toast(context, "复制成功");
                Navigator.of(context).pop();
              },
            ),
          );
      }
    } else {
      return new Container(
        height: 4,
        color: Colors.transparent,
//      ListTile
        child: new Text(""),
      );
    }
  }
}
