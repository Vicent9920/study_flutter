import 'package:flutter/material.dart';
import 'package:study_flutter/bean/article_bean.dart';
import 'package:study_flutter/dao/db/database.dart';
import 'package:study_flutter/generated/i18n.dart';
import 'package:study_flutter/utils/date_util.dart';

class StaredListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _StaredListPageState();
  }
}

class _StaredListPageState extends State<StaredListPage> {
  List<ArticleBean> _articles = [];
  ArticleProvider provider;

  @override
  void initState() {
    provider = ArticleProvider();
    provider.getStarred().then((articles) {
      setState(() => _articles = articles);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(color: Colors.grey);
    return Scaffold(
      appBar: AppBar(
          title: Text(S.of(context).action_starred_list),
          actions: <Widget>[
            IconButton(
              icon: Icon(_articles.length > 0 ? Icons.delete : null),
              onPressed: () {
                showAlertDialog(context, style);
              },
            )
          ],
          backgroundColor: Colors.blue),
      body: buildBody(),
    );
  }

  void showAlertDialog(BuildContext context, TextStyle style) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(S.of(context).title_clear_starred),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    S.of(context).action_cancel,
                    style: style,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                FlatButton(
                  child: Text(
                    S.of(context).action_ok,
                    style: style,
                  ),
                  onPressed: () {
                    provider
                        .clearStarred()
                        .then((_) => provider.getStarred())
                        .then((articles) {
                      setState(() => _articles = articles);
                    });
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  Widget buildBody() {
    if (_articles.length < 1) {
      return Center(
        child: Text(
          S.of(context).content_not_starred,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(itemBuilder: (context, index) {
      final total = _articles.length * 2;
      if (index <= total) {
        if (index.isOdd) return Divider();
        final i = index ~/ 2;

        if (i < _articles.length) {
          DataBean data = _articles[i].data;
          return ListTile(
            title: Text(data.title),
            subtitle: Text(
                "${data.author} - ${getRelatedTime(context, str2Date(data.date.curr))}"),
            trailing: IconButton(
                icon: Icon(Icons.delete),
                color: Colors.black45,
                onPressed: () {
                  _articles[i].starred = false;
                  provider.insertOrReplaceToDB(_articles[i]).then((_) {
                    setState(() => _articles.removeAt(i));
                  });
                }),
            onTap: () {
              Navigator.pop(context, _articles[i]);
            },
          );
        }
      }
    });
  }


}
