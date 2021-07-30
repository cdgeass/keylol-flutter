import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/models/profile.dart';
import 'package:keylol_flutter/pages/avatar.dart';

const String avatarUrl =
    'https://keylol.com/uc_server/avatar.php?size=small&uid=';

class ThreadAuthor extends StatefulWidget {
  final String uid;
  final String username;
  final Size size;

  const ThreadAuthor(
      {Key? key, required this.uid, required this.username, required this.size})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadAuthorState();
}

class _ThreadAuthorState extends State<ThreadAuthor> {
  late Future<Profile> _future;

  @override
  void initState() {
    super.initState();

    _future = Global.keylolClient.fetchProfile(uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
        final avatar =
            Avatar(avatarUrl: avatarUrl + widget.uid, size: widget.size);
        final username = Text(widget.username);

        final children = [
          avatar,
          SizedBox(
            width: 8.0,
          ),
          username
        ];
        if (snapshot.hasData) {
          final profile = snapshot.data!;
          final group = profile.space?.group;
          if (group != null) {
            children.add(SizedBox(
              width: 8.0,
            ));
            children.add(Text(group.groupTitle!,
                style: group.color?.isNotEmpty == true
                ? TextStyle(
                        color: Color(int.parse(group.color!, radix: 16)))
                    : null));
          }

          return Row(children: children);
        }

        return Row(children: children);
      },
    );
  }
}
