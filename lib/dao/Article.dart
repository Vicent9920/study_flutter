import 'package:study_flutter/bean/article_bean.dart';
import 'package:quiver/strings.dart' as strings;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:study_flutter/dao/db/database.dart';
import 'package:study_flutter/utils/date_util.dart';
const String baseUrl = "https://interface.meiriyiwen.com";

const String todayArticle = "/article/today?dev=1";
const String randomArticle = "/article/random?dev=1";
const String somedayArticle = "/article/day?dev=1&date=";

class Article {
  static Future<ArticleBean> today() async {
    return await getArticle(date:formatDate(DateTime.now()));
  }

  static Future<ArticleBean> getArticle({String date}) async {
    ArticleBean articleBean;
    String url;
    if (!strings.isEmpty(date)) {
      if ("today" == date) {
        url = "$baseUrl$todayArticle";
      } else if ("random" == date) {
        url = "$baseUrl$randomArticle";
      } else {
        url = "$baseUrl$somedayArticle$date";
      ArticleProvider provider = ArticleProvider();
      articleBean = await provider.getFromDB(date);
      }
    } else {
      url = "$baseUrl$randomArticle";
    }
    if (articleBean == null) {
      articleBean = await getRequest(url);
    }

    return articleBean;
  }

  static Future<ArticleBean> getRequest(String url) async{
    ArticleBean articleBean;
    http.Response response = await http.get(url);
    if(response.statusCode == 200){
      Map<String, dynamic> jsonStr = json.decode(response.body);
      articleBean = ArticleBean.fromJson(jsonStr);
      DataBean data = articleBean.data;
      if (data.content != null) {
        data.content = data.content
            .replaceAll(RegExp(r"<p>|<P>"), "        ")
            .replaceAll(RegExp(r"</p>|</P>"), "\n\n");
      }
      if (data.date != null) {
        articleBean.date = data.date.curr;
      }
      ArticleProvider provider = ArticleProvider();
      await provider.insertOrReplaceToDB(articleBean);
      return articleBean;
    }
  }
}
