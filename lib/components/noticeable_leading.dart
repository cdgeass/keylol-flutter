import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/provider.dart';
import 'package:provider/provider.dart';

class NoticeableLeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notice = Provider.of<NoticeProvider>(context).notice;

    return Builder(
      builder: (context) {
        if (notice.count() > 0) {
          return IconButton(
            icon: Badge(
              child: Icon(Icons.menu),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        }
      },
    );
  }
}
