import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/components/avatar.dart';

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        late Widget header;
        late Widget notice;
        late Widget login;
        switch (state.status) {
          case AuthenticationStatus.unauthenticated:
            header = UserAccountsDrawerHeader(
              accountName: Text('尚未登录'),
              accountEmail: null,
            );
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
            final profile = state.profile!;

            header = UserAccountsDrawerHeader(
              currentAccountPicture: Avatar(
                uid: profile.memberUid!,
                width: 72.0,
              ),
              accountName: Text(profile.memberUsername!),
              accountEmail: Text(profile.memberUid!),
            );
            notice = ListTile(
              leading: Icon(Icons.notifications_none_outlined),
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

        return Drawer(
          child: ListView(
            children: [
              header,
              index,
              guide,
              forumIndex,
              notice,
              login,
            ],
          ),
        );
      },
    );
  }
}
