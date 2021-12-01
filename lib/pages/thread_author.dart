import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/constants.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/models/profile.dart';
import 'package:keylol_flutter/pages/avatar.dart';

class ThreadAuthor extends StatefulWidget {
  final String uid;
  final String username;
  final Size size;
  final bool needAvatar;
  final double? fontSize;

  ThreadAuthor(
      {Key? key,
      required this.uid,
      required this.username,
      required this.size,
      this.needAvatar = true,
      this.fontSize})
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
        final username = Text(
          widget.username,
          style: TextStyle(fontSize: widget.fontSize),
        );

        final children = [
          if (widget.needAvatar) avatar,
          if (widget.needAvatar)
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
                style: TextStyle(
                    fontSize: widget.fontSize,
                    color: group.color?.isNotEmpty == true
                        ? Color(int.parse(group.color!, radix: 16))
                        : null)));
          }

          return Row(
              crossAxisAlignment: CrossAxisAlignment.end, children: children);
        }

        return Row(
            crossAxisAlignment: CrossAxisAlignment.end, children: children);
      },
    );
  }
}
