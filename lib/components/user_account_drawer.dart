import 'dart:math';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/common/provider.dart';
import 'package:keylol_flutter/common/theme.dart';
import 'package:keylol_flutter/models/profile.dart';
import 'package:provider/provider.dart';

class UserAccountDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserAccountDrawerState();
}

class _UserAccountDrawerState extends State<UserAccountDrawer> {
  @override
  Widget build(BuildContext context) {
    return _buildDrawerContent(Provider.of<ProfileProvider>(context).profile);
  }

  Widget _buildDrawerContent(Profile? profile) {
    var items = List<Widget>.empty(growable: true);

    final avatarProvider = profile?.memberAvatar == null
        ? ExactAssetImage(
            'images/unknown_avatar.jpg',
          )
        : CachedNetworkImageProvider(
                profile!.memberAvatar!.replaceFirst('small', 'middle'))
            as ImageProvider<Object>;
    final drawerHeader = UserAccountsDrawerHeader(
      accountName: Text(profile?.memberUsername ?? '匿名用户'),
      accountEmail: Text(profile?.memberUid ?? ''),
      currentAccountPicture: InkWell(
          onTap: () {
            if (profile != null) {
              Navigator.of(context)
                  .pushNamed('/profile', arguments: profile.memberUid!);
            }
          },
          child: CircleAvatar(
            backgroundImage: avatarProvider,
          )),
    );
    items.add(drawerHeader);

    final index = ListTile(
        leading: Icon(Icons.home),
        title: Text('聚焦'),
        onTap: () {
          Navigator.of(context).pushNamed('/index');
        });
    items.add(index);

    final forums = ListTile(
        leading: Icon(Icons.dashboard),
        title: Text('版块'),
        onTap: () {
          Navigator.of(context).pushNamed('/forumIndex');
        });
    items.add(forums);

    if (profile != null) {
      final notice = Provider.of<NoticeProvider>(context).notice;
      late Widget leading;
      if (notice.count() > 0) {
        leading = Badge(
          child: Icon(Icons.notifications),
        );
      } else {
        leading = Icon(Icons.notifications);
      }

      final noticeWidget = ListTile(
          leading: leading,
          title: Text('提醒'),
          onTap: () {
            Provider.of<NoticeProvider>(context).clear();
            Navigator.of(context).pushNamed('/noteList');
          });
      items.add(noticeWidget);
    }

    final theme = ListTile(
      leading: Icon(Icons.color_lens),
      title: Text('主题'),
      onTap: () {
        final index = Random().nextInt(colors.length);
        Provider.of<ThemeProvider>(context).update(colors[index]);
      },
    );
    items.add(theme);

    final loginOrLogout = ListTile(
      leading: profile == null ? Icon(Icons.login) : Icon(Icons.logout),
      title: Text(profile == null ? '登录' : '退出'),
      onTap: () {
        if (profile == null) {
          Navigator.of(context).pushNamed("/login");
        } else {
          Provider.of<NoticeProvider>(context).clear();
          Provider.of<ProfileProvider>(context).clear();
          KeylolClient().clearCookies();
        }
      },
    );
    items.add(loginOrLogout);

    final drawItems = ListView(
      children: items,
    );

    return Drawer(
      child: drawItems,
    );
  }
}

Widget buildAppBarLeading(BuildContext context) {
  final notice = Provider.of<NoticeProvider>(context).notice;
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
}
