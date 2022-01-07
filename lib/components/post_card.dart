import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/notifiers.dart';
import 'package:keylol_flutter/components/avatar.dart';

class PostCard extends StatefulWidget {
  final String authorId;
  final String author;
  final String dateline;
  final String pid;
  final Widget content;
  final String tid;

  const PostCard(
      {Key? key,
      required this.authorId,
      required this.author,
      required this.dateline,
      required this.pid,
      required this.content,
      required this.tid})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Avatar(
              uid: widget.authorId,
              size: AvatarSize.middle,
              width: 40.0,
            ),
            title: Text(widget.author),
            subtitle: Text(widget.dateline),
          ),
          widget.content,
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    // TODO 回复
                  },
                  icon: Icon(Icons.reply_outlined)),
              if (ProfileNotifier().profile?.memberUid == widget.authorId)
                IconButton(
                    onPressed: () {
                      // TODO 编辑
                    },
                    icon: Icon(Icons.edit)),
              IconButton(
                  onPressed: () {
                    // TODO 支持
                  },
                  icon: Icon(Icons.plus_one_outlined)),
            ],
          )
        ],
      ),
    );
  }
}
