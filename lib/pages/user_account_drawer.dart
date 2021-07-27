import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/model/profile.dart';
import 'package:provider/provider.dart';

class UserAccountDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserAccountDrawerState();
}

class _UserAccountDrawerState extends State<UserAccountDrawer> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Global.profileHolder,
      child: Consumer<ProfileHolder>(
        builder: (context, notifier, child) {
          return _buildDrawerContent(notifier.profile);
        },
      ),
    );
  }

  Widget _buildDrawerContent(Profile? profile) {
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
      currentAccountPicture: CircleAvatar(
        backgroundImage: avatarProvider,
      ),
    );
    final loginOrLogout = ListTile(
      leading: profile == null ? Icon(Icons.login) : Icon(Icons.logout),
      title: Text(profile == null ? '登陆' : '退出'),
      onTap: () {
        if (profile == null) {
          Navigator.of(context).pushNamed("/login");
        } else {
          Global.logout();
        }
      },
    );
    final drawItems = ListView(
      children: [
        drawerHeader,
        // TODO other menus
        loginOrLogout,
      ],
    );
    return Drawer(
      child: drawItems,
    );
  }
}
