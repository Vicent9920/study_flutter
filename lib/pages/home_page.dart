import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_flutter/bean/article_bean.dart';
import 'package:study_flutter/dao/Article.dart';
import 'package:study_flutter/dao/db/database.dart';
import 'package:study_flutter/generated/i18n.dart';
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
  final platform = const MethodChannel("samples.flutter.io/share");
  String date = formatDate(DateTime.now());

  _HomePageState(this.article);

  double _fontSize = 18;
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
                    icon: Icon(Icons.more_vert),
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
                              "(${getRelatedTime(context, str2Date(article.data.date.curr))}，${S.of(context).author}：${article.data.author}，${S.of(context).word_count}：${article.data.wc})",
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
                      article.data.content,
                      style: TextStyle(fontSize: _fontSize),
                      textAlign: TextAlign.start,
                    ))
                  ],
                ),
                color: themeColors[5]),
          )),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return new FloatingActionButton(
          child: const Icon(Icons.date_range),
          tooltip: S.of(context).select_date,
          foregroundColor: Colors.white,
          backgroundColor: themeColors[_themeColorIndex],
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
        // api的初始日期
        firstDate: DateTime(2012, 4,15),
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
                  S.of(context).action_cancel,
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
      return new Padding(
        padding: EdgeInsets.fromLTRB(36, 0, 36.0, 0),
        child: MaterialButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _iconData(index),
                color: Colors.white,
              ),
              Container(
                width: 6,
              ),
              Text(
                _itemText(index),
                style: style,
              )
            ],
          ),
          color: Colors.blue,
          onPressed: () {
            _onPressed(index);
          },
        ),
      );
    } else {
      return new Container(
        height: 4,
        color: Colors.transparent,
//      ListTile
        child: new Text(""),
      );
    }
  }

  IconData _iconData(int index) {
    IconData iconData = null;
    switch (index) {
      case 1:
        iconData = article?.starred ? Icons.star : Icons.star_border;
        break;
      case 3:
        iconData = Icons.content_copy;
        break;
      case 5:
        iconData = Icons.share;
        break;
    }
    return iconData;
  }

  String _itemText(int index) {
    String text = "";
    switch (index) {
      case 1:
        text = article?.starred
            ? S.of(context).action_starred
            : S.of(context).action_not_starred;
        break;
      case 3:
        text = S.of(context).copy_content;
        break;
      case 5:
        text = S.of(context).action_share;
        break;
    }
    return text;
  }

  void _onPressed(int index) {
    switch (index) {
      case 1:
        onStarPressed();
        break;
      case 3:
        ClipboardData data = new ClipboardData(
            text:
                "${article.data.title}，作者：${article.data.author}，字数：${article.data.wc})\n${article?.data.content}");
        Clipboard.setData(data);
        Toast.toast(context, "复制成功");
        break;
      case 5:
        platform.invokeMethod("shareMsg",
            "来自烤鱼的一文APP：\n${article.data.title}，作者：${article.data.author}，字数：${article.data.wc})\n${article?.data.content}");
        break;
    }
    Navigator.of(context).pop();
  }
}
