import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/styling.dart';
import 'package:keylol_flutter/components/avatar.dart';

class IndexThreadCard extends StatefulWidget {
  final String tid;
  final String title;
  final String dateline;
  final String authorId;
  final String author;

  const IndexThreadCard(
      {Key? key,
      required this.tid,
      required this.title,
      required this.dateline,
      required this.authorId,
      required this.author})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _IndexThreadCardState();
}

class _IndexThreadCardState extends State<IndexThreadCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/thread', arguments: widget.tid);
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.author} - ${widget.dateline}',
                        style: AppTheme.caption
                            .copyWith(color: AppTheme.darkText)),
                    const SizedBox(height: 2.0),
                    Text(widget.title,
                        style:
                            AppTheme.title.copyWith(color: AppTheme.darkText))
                  ],
                )),
                Avatar(
                  uid: widget.authorId,
                  size: AvatarSize.middle,
                  width: 36.0,
                )
              ],
            ),
          )),
    );
  }
}

typedef ContentBuilder = Widget Function(Widget child);

class ThreadCard extends StatefulWidget {
  final String tid;
  final String subject;
  final String authorId;
  final String author;
  final String dateline;
  final ContentBuilder? contentBuilder;

  const ThreadCard(
      {Key? key,
      required this.tid,
      required this.subject,
      required this.authorId,
      required this.author,
      required this.dateline,
      this.contentBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadCard();
}

class _ThreadCard extends State<ThreadCard> {
  @override
  Widget build(BuildContext context) {
    final content = ListTile(
      leading: Avatar(
        uid: widget.authorId,
        size: AvatarSize.middle,
        width: 40.0,
      ),
      title: Text(widget.subject),
      subtitle: Text('${widget.author} - ${widget.dateline}'),
    );
    return Card(
      elevation: 1.0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/thread', arguments: widget.tid);
        },
        child: widget.contentBuilder == null
            ? content
            : widget.contentBuilder!.call(content),
      ),
    );
  }
}
