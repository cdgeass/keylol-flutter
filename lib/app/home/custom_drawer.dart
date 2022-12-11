import 'package:about/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/common/check_version.dart';
import 'package:keylol_flutter/repository/authentication_repository.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  void _onSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        break;
      case 1:
        Navigator.of(context).pushNamed('/fav');
        break;
      case 2:
        Navigator.of(context).pushNamed('/history');
        break;
      case 3:
        _showAboutPage(context);
        break;
      case 4:
        context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
        Navigator.of(context).pop();
        break;
    }
  }

  void _showAboutPage(BuildContext context) {
    showAboutPage(
      context: context,
      values: {
        'version': 'v2.0.0',
      },
      applicationLegalese: 'Author @cdgeass',
      children: <Widget>[
        ListTile(
          title: Text('检查更新'),
          onTap: () {
            CheckVersion().checkVersion().then(
              (url) {
                if (url != null) {
                  showDialog<void>(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: Text('有新版本!前往下载'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              launchUrlString(url,
                                  mode: LaunchMode.externalApplication);
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog<void>(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: Text('已是最新版本'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            );
          },
        ),
        ListTile(
          title: Text('Github'),
          onTap: () {
            launchUrlString(
              'https://github.com/cdgeass/keylol-flutter',
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        LicensesPageListTile(),
      ],
      applicationIcon: const SizedBox(
        width: 100,
        height: 100,
        child: Image(
          image: AssetImage('images/icon-350x350.png'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final profile = context.read<AuthenticationRepository>().profile;
        return NavigationDrawer(
          onDestinationSelected: (index) => _onSelected(context, index),
          selectedIndex: 0,
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            Container(
              padding: EdgeInsets.only(left: 12.0, right: 12.0),
              height: 56.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16.0),
                  Text(
                    'KeylolF',
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                ],
              ),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.home),
              label: Text('主页'),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.favorite),
              label: Text('收藏'),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.history),
              label: Text('历史'),
            ),
            NavigationDrawerDestination(
              icon: Icon(null),
              label: Text('关于'),
            ),
            Expanded(child: Container()),
            if (profile != null && profile.memberUid != '0')
              Container(
                padding: EdgeInsets.only(left: 28.0, right: 28.0),
                child: Divider(
                  thickness: 0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            if (profile != null && profile.memberUid != '0')
              NavigationDrawerDestination(
                icon: Icon(Icons.login),
                label: Text('退出'),
              ),
          ],
        );
      },
    );
  }
}
