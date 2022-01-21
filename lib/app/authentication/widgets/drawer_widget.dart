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
        late Widget login;
        switch (state.status) {
          case AuthenticationStatus.unauthenticated:
            header = UserAccountsDrawerHeader(
              accountName: Text('尚未登录'),
              accountEmail: null,
            );
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
            login = ListTile(
              leading: Icon(Icons.logout),
              title: Text('退出'),
              onTap: () {},
            );
            break;
        }

        return Drawer(
          child: ListView(
            children: [
              header,
              login,
            ],
          ),
        );
      },
    );
  }
}
