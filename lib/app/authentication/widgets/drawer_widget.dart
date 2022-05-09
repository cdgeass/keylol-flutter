import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/app/notice/widgets/notice_badge.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/settings/settings.dart';

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuCubit, List<String>>(
      builder: (context, menus) {
        return BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            late Widget header;

            // 收藏
            late Widget favThread;

            // 提醒
            late Widget notice;

            // 登录/退出
            late Widget login;

            late double height;

            switch (state.status) {
              case AuthenticationStatus.unauthenticated:
                height = 224.0;
                header = UserAccountsDrawerHeader(
                  accountName: Text('尚未登录'),
                  accountEmail: null,
                );
                favThread = SizedBox.shrink();
                notice = SizedBox.shrink();
                login = ListTile(
                  leading: Icon(Icons.login),
                  title: Text('登录'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/login');
                  },
                );
                break;
              case AuthenticationStatus.authenticated:
                height = 336.0;
                final profile = state.profile!;
                header = UserAccountsDrawerHeader(
                  currentAccountPicture: Avatar(
                    uid: profile.memberUid!,
                    width: 72.0,
                  ),
                  accountName: Text(profile.memberUsername!),
                  accountEmail: Text(profile.memberUid!),
                );
                favThread = ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('收藏'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/favThread');
                  },
                );
                notice = ListTile(
                  leading: NoticeBadge(
                    child: Icon(Icons.notifications),
                  ),
                  title: Text('提醒'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/notice');
                  },
                );
                login = ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('退出'),
                  onTap: () {
                    context
                        .read<AuthenticationBloc>()
                        .add(AuthenticationLogoutRequested());
                  },
                );
                break;
            }

            // 聚焦
            final index = ListTile(
              leading: Icon(Icons.home),
              title: Text('聚焦'),
              onTap: () {
                Navigator.of(context).pushNamed('/index');
              },
            );

            // 导读
            final guide = ListTile(
              leading: Icon(Icons.camera),
              title: Text('导读'),
              onTap: () {
                Navigator.of(context).pushNamed('/guide');
              },
            );

            // 版块
            final forumIndex = ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('版块'),
              onTap: () {
                Navigator.of(context).pushNamed('/forum');
              },
            );

            final history = ListTile(
              leading: Icon(Icons.history),
              title: Text('历史'),
              onTap: () {
                Navigator.of(context).pushNamed('/history');
              },
            );

            final menuMap = {
              'index': index,
              'guide': guide,
              'forumIndex': forumIndex,
              'favThread': favThread,
              'notice': notice,
              'history': history,
            };

            return Drawer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  header,
                  Container(
                    height: height,
                    child: ReorderableListView(
                      children: [
                        for (final menu in menus)
                          Container(
                            key: ValueKey(menuMap[menu]),
                            child: menuMap[menu],
                          )
                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        final oldMenu = menus[oldIndex];

                        final beforeMenus = menus
                            .sublist(0, newIndex)
                            .where((e) => e != oldMenu)
                            .toList();
                        final afterMenus = menus
                            .sublist(newIndex)
                            .where((e) => e != oldMenu)
                            .toList();

                        final newMenus = [
                          for (final beforeMenu in beforeMenus) beforeMenu,
                          oldMenu,
                          for (final afterMenu in afterMenus) afterMenu
                        ];

                        context.read<MenuCubit>().updateMenus(newMenus);
                      },
                    ),
                  ),
                  login,
                ],
              ),
            );
          },
        );
      },
    );
  }
}
