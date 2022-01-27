import 'package:flutter/material.dart';
import 'package:keylol_flutter/app/thread/view/view.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/app/thread/models/thread.dart';

typedef ThreadBuilder = Widget Function(Widget child);

class ThreadCard extends StatelessWidget {
  final Thread thread;
  final ThreadBuilder? builder;

  const ThreadCard({Key? key, required this.thread, this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = ListTile(
      leading: thread.authorId.isEmpty
          ? null
          : Avatar(
              uid: thread.authorId,
              size: AvatarSize.middle,
              width: 40.0,
            ),
      title: Text(thread.subject),
      subtitle: thread.author.isEmpty
          ? null
          : Text('${thread.author} - ${thread.dateline}'),
    );
    return Card(
      elevation: 1.0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ThreadPage(tid: thread.tid)));
        },
        child: builder == null ? content : builder!.call(content),
      ),
    );
  }
}
