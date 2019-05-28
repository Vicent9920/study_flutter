import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_flutter/bean/event.dart';
import 'package:study_flutter/generated/i18n.dart';
import 'package:study_flutter/utils/constant.dart';
import 'package:study_flutter/utils/sp_store_util.dart';

class SelectDialog extends StatefulWidget {
  final int index;

  const SelectDialog({Key key, this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SelectDialogState();
  }
}

class _SelectDialogState extends State<SelectDialog>
    with SingleTickerProviderStateMixin {
  int index = 0;
  Future<void> callback;
  TabController _tabController;

  @override
  void initState() {
    index = widget.index;
    _tabController =
        new TabController(initialIndex: index, length: 5, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).select_color_dialog_title),
      content: Container(
        child: TabBar(
          tabs: themeTabs(index),
          isScrollable: false,
          controller: _tabController,
//            indicatorPadding: const EdgeInsets.only(left: 12, right: 12),
          indicator: const BoxDecoration(),
          onTap: (int) {
            //Bus触发事件
            eventBus.fire(new SelectColorEvent(int));
            setState(() {
              index = int;
            });
          },
//            indicatorColor: themeColors[index],
//            indicatorSize: TabBarIndicatorSize.label
        ),
      ),
      actions: <Widget>[
        new CupertinoButton(
            onPressed: () {
              onTap();
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).action_cancel)),
        new CupertinoButton(
            onPressed: () {
              onTap();
              Navigator.of(context).pop();
              // 保存主题颜色
            },
            child: Text(S.of(context).action_ok)),
      ],
    );
  }

  List<Tab> themeTabs(int _themeColorIndex) {
    List<Tab> tabs = List();
    for (Color color in themeColors) {
      if (color == themeColors.last) {
        continue;
      }
      if (color == themeColors[_themeColorIndex]) {
        tabs.add(Tab(icon: Icon(Icons.check_box, color: color)));
      } else {
        tabs.add(Tab(icon: Icon(Icons.check_box_outline_blank, color: color)));
      }
    }
    return tabs;
  }

  void onTap() {
    var lastIndex = getThemeColor();
    lastIndex.then((oldValue) {
      if (index != oldValue) {
        //Bus触发事件
        eventBus.fire(new SelectColorEvent(oldValue));
        setState(() {
          index = oldValue;
        });
      } else {
        storeThemeColor(index);
      }
    });
  }
}
