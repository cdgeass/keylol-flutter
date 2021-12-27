import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/models/space.dart';

class ThreadAuthor extends StatefulWidget {
  final String uid;
  final String username;
  final AvatarSize size;
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
  late Future<Space> _future;

  @override
  void initState() {
    super.initState();

    _future = KeylolClient().fetchProfile(uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<Space> snapshot) {
        final avatar = Avatar(
          uid: widget.uid,
          size: widget.size,
          width: 36.0,
        );
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
          final group = snapshot.data!.group;
          children.add(SizedBox(
            width: 8.0,
          ));
          children.add(Text(group.groupTitle!,
              style: TextStyle(fontSize: widget.fontSize, color: group.color)));
        }

        return Row(
            crossAxisAlignment: CrossAxisAlignment.end, children: children);
      },
    );
  }
}
