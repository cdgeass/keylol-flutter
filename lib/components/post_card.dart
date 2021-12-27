import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/components/avatar.dart';

class PostCard extends StatefulWidget {
  final String authorId;
  final String author;
  final String dateline;
  final String pid;
  final Widget content;

  const PostCard(
      {Key? key,
      required this.authorId,
      required this.author,
      required this.dateline,
      required this.pid,
      required this.content})
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
              IconButton(
                  onPressed: () {
                    // TODO
                  },
                  icon: Icon(Icons.favorite_border_outlined)),
              IconButton(
                  onPressed: () {
                    // TODO
                  },
                  icon: Icon(Icons.thumb_up_outlined))
            ],
          )
        ],
      ),
    );
  }
}
