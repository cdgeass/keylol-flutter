import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/notifiers.dart';
import 'package:keylol_flutter/components/avatar.dart';

class PostCard extends StatefulWidget {
  final String authorId;
  final String author;
  final String dateline;
  final String pid;
  final Widget content;
  final bool first;
  final String tid;
  final bool favored;

  const PostCard(
      {Key? key,
      required this.authorId,
      required this.author,
      required this.dateline,
      required this.pid,
      required this.content,
      this.first = false,
      required this.tid,
      this.favored = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      clipBehavior: Clip.antiAlias,
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
          Padding(
            padding: EdgeInsets.all(8.0),
            child: widget.content,
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              if (widget.first)
                IconButton(
                    onPressed: () {
                      // TODO 评分
                    },
                    icon: Icon(Icons.thumb_up_outlined)),
              if (!widget.first)
                IconButton(
                    onPressed: () {
                      // TODO 回复
                    },
                    icon: Icon(Icons.reply_outlined)),
              if (!widget.first &&
                  ProfileNotifier().profile?.memberUid == widget.authorId)
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
