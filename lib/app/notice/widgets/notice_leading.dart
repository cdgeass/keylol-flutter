import 'package:flutter/material.dart';
import 'package:keylol_flutter/app/notice/widgets/widgets.dart';

class NoticeLeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return IconButton(
          icon: NoticeBadge(
            child: Icon(Icons.menu),
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      },
    );
  }
}
